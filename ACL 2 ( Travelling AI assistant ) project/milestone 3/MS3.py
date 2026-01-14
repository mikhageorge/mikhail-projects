import streamlit as st
import os
from dotenv import load_dotenv
from streamlit_chat import message
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_huggingface import ChatHuggingFace
from langchain_classic.chains import create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.language_models import LLM
from pydantic import Field
from typing import Any, List, Optional
from huggingface_hub import InferenceClient
import aclmilestone3 
import streamlit as st
import os
import requests
import json
import time
import re



# --- CONFIGURATION ---
ST_PAGE_TITLE = "Hotel & Visa Assistant"

load_dotenv()

# Parse thinking for thinking models
def parse_thinking(response):
    thought_match = re.search(r'<thinking>(.*?)</thinking>', response, re.DOTALL)
    if thought_match:
        thought_content = thought_match.group(1).strip()
        final_answer = re.sub(r'<thinking>.*?</thinking>', '', response, flags=re.DOTALL).strip()
        return thought_content, final_answer
    return None, response

# --- 1. LLM HANDLER (Part 3) ---
def query_LLM(LLM_Option , user_input , KG_data):
    """
    Sends the chat history and context to OpenRouter.
    """

    # Extract the 3 components from context_list
    # Expected format: [cypher_query_result, embedding_answer, additional_context]
    if(KG_data is None):
        cypher_query = ""
        cypher_query_answer = ""
        embedding_answer = ""
    else:
        cypher_query = KG_data["cypher_query"]
        cypher_query_answer = KG_data["cypher_query_answer"]
        embedding_answer = KG_data["embedding_answer"]

    system_prompt = f"""You are an expert Travel Assistant. Your goal is to provide accurate, data-driven answers based ONLY on the provided context.

### 1. CONTEXT DATA
<cypher_logic>
{cypher_query}
</cypher_logic>

<structured_data_source_of_truth>
{cypher_query_answer}
</structured_data_source_of_truth>

<unstructured_data_reviews_and_rules>
{embedding_answer}
</unstructured_data_reviews_and_rules>

### 2. INSTRUCTIONS
- **Source of Truth:** The <structured_data> is your ground truth for facts (names, locations, star ratings, scores). If <unstructured_data> conflicts with it, trust the structured data.
- **Scores:** If the user asks for recommendations, "best" hotels, or comparisons, you MUST explicitly mention the scores (e.g., "**9.5/10**") to justify your answer.
- **Formatting:** 
  - Use **bold** for hotel names and key metrics.
  - Use bullet points for lists.
  - Keep answers concise and professional.
- **Missing Info:** If the answer is not in the context, strictly reply: "I'm sorry, I don't have that information in my database." Do not hallucinate.
"""
    
    if LLM_Option == "Gemma 3 4B (Local LLM)":
        url= ""
        headers = { "Content-Type": "application/json" }
        payload = {
            "model": 'google/gemma-3-4b',
            "temperature": 0.2,
            "messages": [
                {
                    "role": "system",
                    "content": [{
                    "type": "text",
                    "text": system_prompt
                        
                    }]         
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": user_input
                        }
                    ]
                }
                        ]
        }
        # Measure latency
        start_time = time.time()
        try:
            api_response = requests.post(url, headers=headers, json=payload)
            latency = time.time() - start_time
            
            if api_response.status_code == 200:
                result = api_response.json()
                response = result['choices'][0]['message']['content']
                
                # Extract token usage (split into input and output)
                usage = result.get("usage", {})
                input_tokens = usage.get("prompt_tokens", 0)
                output_tokens = usage.get("completion_tokens", 0)
                total_tokens = usage.get("total_tokens", 0)
                # TODO: Calculate cost based on model pricing
                cost = 0 
                
                analytics = {
                    "cost": cost,
                    "input_tokens": input_tokens,
                    "output_tokens": output_tokens,
                    "total_tokens": total_tokens,
                    "latency_seconds": round(latency, 3)
                }
            else:
                response = f"Error {api_response.status_code}: {api_response.text}"
                analytics = {}
        except Exception as e:
            response = f"Connection Error: {str(e)}"
            analytics = {}
    else: # OPEN ROUNTER CALL
            
        load_dotenv()
        api_key = os.getenv("")
        if not api_key:
            raise ValueError("OPENROUTER_API_KEY environment variable not set")
        


        # Set up the API request to OpenRouter
        url = ""
        headers = {
            "Authorization": f"Bearer {api_key}",
            "HTTP-Referer": "http://localhost",
            "X-Title": "ACL3"
        }
        
        
        payload = {
            "model": LLM_Option,
            "temperature": 0.2,
            "messages": [
                {
                    "role": "system",
                    "content": system_prompt
                },
                {
                    "role": "user",
                    "content": user_input
                }
            ]
        }

        # Measure latency
        start_time = time.time()
        api_response = requests.post(url, headers=headers, json=payload)
        latency = time.time() - start_time
        
        api_response.raise_for_status()
        
        result = api_response.json()
        response = result["choices"][0]["message"]["content"]
        
        # Extract token usage (split into input and output)
        usage = result.get("usage", {})
        input_tokens = usage.get("prompt_tokens", 0)
        output_tokens = usage.get("completion_tokens", 0)
        total_tokens = usage.get("total_tokens", 0)
        
        cost = 0  #TODO 
        
        analytics = {
            "cost": cost,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "total_tokens": total_tokens,
            "latency_seconds": round(latency, 3)
        }
        
    
    


    
    return response ,  analytics


# --- 2. MOCK BACKEND (Placeholder for Parts 1 & 2) ---
def mock_backend_retrieval(user_query, method):
    """
    Simulates what your teammates' code will return.
    Replace this function with the actual import later!
    """
    time.sleep(0.5) # Fake latency
    
    # Fake Cypher Query
    cypher_query = f"MATCH (h:Hotel)-[:LOCATED_IN]->(c:City) WHERE c.name CONTAINS '{user_query.split()[-1]}' RETURN h"
    
    # Fake Data based on method
    if "Baseline" in method:
        data = [{"name": "Ramses Hilton", "city": "Cairo", "price": "$120", "visa_policy": "Visa on arrival"}]
    elif "Embeddings" in method:
        data = [{"name": "Airbnb Zamalek", "city": "Cairo", "desc": "Cozy place...", "similarity_score": 0.89}]
    else: # Hybrid
        data = [
            {"name": "Ramses Hilton", "source": "Cypher"}, 
            {"name": "Airbnb Zamalek", "source": "Vector"}
        ]
        
    return data, cypher_query





# --- testing LLM function ---
#TODO create a function that performs the test on the prompts and records the results

def test_invoke_LLM(LLM_Options , user_input_list ):

    all_responses = []
    Analytics_Results = []
    
    for LLM_Option in LLM_Options:
        print(f"\n{'='*50}")
        print(f"Testing Model: {LLM_Option}")
        print(f"{'='*50}")
        
        response_list = []
        model_analytics_list = []
        for user_input in user_input_list:
            KG_data = aclmilestone3.input_to_KG( user_input = user_input, embedding_model_choice = "minilm", retrieval_choice= "Cypher Only" )
            print(f"  Testing with input: {user_input}")
            response, analytics = query_LLM(LLM_Option, user_input, KG_data)
            response_list.append(response)
            all_responses.append(response)
            model_analytics_list.append(analytics)
        
        # Calculate average analytics for this model
        avg_analytics = {
            "model": LLM_Option,
            "num_tests": len(model_analytics_list),
            "avg_cost": round(sum(a["cost"] for a in model_analytics_list) / len(model_analytics_list), 4),
            "avg_input_tokens": round(sum(a["input_tokens"] for a in model_analytics_list) / len(model_analytics_list), 2),
            "avg_output_tokens": round(sum(a["output_tokens"] for a in model_analytics_list) / len(model_analytics_list), 2),
            "avg_total_tokens": round(sum(a["total_tokens"] for a in model_analytics_list) / len(model_analytics_list), 2),
            "avg_latency_seconds": round(sum(a["latency_seconds"] for a in model_analytics_list) / len(model_analytics_list), 3)
        }
        
        Analytics_Results.append(avg_analytics)
        
        # Print results for this model
        print(f"\n  Model: {LLM_Option}")
        print(f"  Tests performed: {avg_analytics['num_tests']}")
        print(f"  Avg Cost: {avg_analytics['avg_cost']}")
        print(f"  Avg Input Tokens: {avg_analytics['avg_input_tokens']}")
        print(f"  Avg Output Tokens: {avg_analytics['avg_output_tokens']}")
        print(f"  Avg Total Tokens: {avg_analytics['avg_total_tokens']}")
        print(f"  Avg Latency: {avg_analytics['avg_latency_seconds']}s")
        print("-" * 50)
        
    return Analytics_Results , all_responses



# --- 3. STREAMLIT UI (Part 4) ---
st.set_page_config(page_title=ST_PAGE_TITLE, layout="wide")

st.title(f"{ST_PAGE_TITLE} (Graph-RAG)")
st.markdown("Milestone 3 | Hotel Theme | Graph-Grounded LLM")

# --- SIDEBAR ---
with st.sidebar:
    st.header(" Experiment Controls")
    
    # 4.c: Model Comparison
    selected_model = st.selectbox(
        " Select LLM Model",
        options=[
            "Gemma 3 4B (Local LLM)",  # Local Model Option #WORKING
            "moonshotai/kimi-k2:free", #WORKING
               "openai/gpt-oss-20b:free", #WORKING
               #"nex-agi/deepseek-v3.1-nex-n1:free", #Claude 

        ],
        index=0
    )
    
    # 4.c: Retrieval Method Selection
    retrieval_method = st.radio(
        "Retrieval Method",
        options=["Cypher Only", "Embeddings Only", "Hybrid"],
        help="Choose how to retrieve context: via Cypher queries, vector embeddings, or both."
    )

    embedding_method = st.radio(
        "Embedding Model",
        options=["all-MiniLM-L6-v2", "all-mpnet-base-v2"],
        help="Select the embedding model for vector search."
    )
    
    st.divider()
    st.info("💡 **Tip:** Use 'Hybrid' to see combined results from Keywords and Vectors.")

# --- CHAT STATE ---
if "messages" not in st.session_state:
    st.session_state.messages = []

# --- DISPLAY HISTORY ---
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        # If there is debug info attached to this message, show it
        

# --- USER INPUT ---
if prompt := st.chat_input("Ask about hotels or visa requirements..."):
    
    # 1. Show User Message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # 2. Generate Assistant Response
    with st.chat_message("assistant"):

            # A. CALL BACKEND 
            KG = aclmilestone3.input_to_KG(prompt, embedding_model_choice = embedding_method, retrieval_choice= retrieval_method)
            
            
            
            # C. CALL LLM
            start_time = time.time()
            response_text , analytics = query_LLM( selected_model, prompt, KG )
            latency = round(time.time() - start_time, 2)
            
            print("Analytics:", analytics)
            with st.expander("📊 Response Analytics", expanded=False):
                col1, col2, col3 = st.columns(3)
                col1.metric("Latency", f"{analytics.get('latency_seconds', 0)}s")
                col2.metric("Input Tokens", analytics.get('input_tokens', 0))
                col3.metric("Output Tokens", analytics.get('output_tokens', 0))
                
                col4, col5 = st.columns(2)
                col4.metric("Total Tokens", analytics.get('total_tokens', 0))
                col5.metric("Est. Cost", f"${analytics.get('cost', 0)}")


            # D. DISPLAY RESPONSE

            #In case of embeddings only or Hybrid show the KG embeddings answer
            #if retrieval_method == "Hybrid" or retrieval_method == "Embeddings Only":
            #    st.markdown("KG-retrieved context used to answer:")
            #    st.markdown(f'{KG["embedding_answer"]}')

            #if retrieval_method == "Hybrid" or retrieval_method == "Cypher Only":
            #    st.markdown("Cypher context used to answer:")
            #    st.markdown(f"{KG['cypher_query']}")
            #    st.markdown(f'{KG["cypher_query_answer"]}')

            st.markdown(response_text)
            st.caption(f"⚡ Model: {selected_model} | Latency: {latency}s")
            
            # E. SHOW DEBUG INFO (Immediate Transparency)
            with st.expander("🛠️ Graph-RAG Details", expanded=False):
                st.subheader("1. Cypher Query Executed")
                st.code(KG["cypher_query"], language="cypher")
                st.subheader("2. Cypher Query Results")
                st.code(KG["cypher_query_answer"], language="json")
                
                st.subheader("3. Retrieved Embeddings Context")
                st.code(KG["embedding_answer"], language="json")
                #st.json(context_data)

    # 3. SAVE TO HISTORY (Include debug info for persistence)
    st.session_state.messages.append({
        "role": "assistant", 
        "content": response_text,
        "debug_info": {
            #"cypher": cypher_used,
            #"context": context_data
        }
    })















