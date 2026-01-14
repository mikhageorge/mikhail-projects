import time
import pandas as pd
import chromadb
import json
import re
import google.generativeai as genai
from neo4j import GraphDatabase , exceptions
from sentence_transformers import SentenceTransformer
from langchain_huggingface import HuggingFaceEmbeddings


#=========================================================
# here we will do all the configuartion we want to do for the app 

#########3 Configure Gemini API Key
# gemini-2.5-flash-preview-09-2025
# gemini-2.5-flash
# gemini-2.0-flash
# gemini-2.5-pro
# gemma-3-27b-it
GEMINI_API_KEY = ""
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemma-3-27b-it')
############




#####3 leave this for testing purposes
# print("--- List of Available Models ---")
# for m in genai.list_models():
#     # Filter for models that can generate text/chat
#     if 'generateContent' in m.supported_generation_methods:
#         print(f"Name: {m.name}")
#         # print(f"Description: {m.description}") # Uncomment to see details
###############



#=========================================================



#========================================== Hamza's Test Code ==========================================
""" analytics, responses = test_invoke_LLM(
    LLM_Options=[
        #"Gemma 3 4B (Local LLM)",  
        #    "moonshotai/kimi-k2:free", 
               "openai/gpt-oss-20b:free",

    ],
    user_input_list=[
        "I want hotels in New York",
        "Get me 5 star hotels "
        "Get me the highest rated hotel in Paris",
        "Do you have any hidden gems in London ?",
        "What is the best hotel for couples",
    ]
) """



#========================================== Mikhail's Code ==========================================

# this will be used to get the entity names from the neo4j database 
# Connects to Neo4j to get the list of valid Cities, Countries, and Hotels
# ensuring we only extract entities that actually exist in our knowledge graph .
def fetch_knowledge_base(driver):
    kb = {
        "cities": [],
        "countries": [],
        "hotels": []
    }
    
    print("   ...Fetching valid entities from Neo4j...")
    with driver.session() as session:
        # Get Cities
        result = session.run("MATCH (c:City) RETURN c.name as name")
        kb["cities"] = [r["name"] for r in result]
        
        # Get Countries
        result = session.run("MATCH (c:Country) RETURN c.name as name")
        kb["countries"] = [r["name"] for r in result]
        
        # Get Hotels
        result = session.run("MATCH (h:Hotel) RETURN h.name as name")
        kb["hotels"] = [r["name"] for r in result]
        
    return kb

# in this function , we will use gemini to classify the intent of the user input into 10 specfic intents 
def classify_intent(user_text):
    system_prompt = """
    You are the Intent Classifier for a Hotel Recommendation App.
    Your job is to classify the User's Input into EXACTLY ONE of the following 11 intent labels.
    
    THE 11 VALID INTENTS & EXAMPLES:
    
    1. search_by_city
       - Description: User wants to find hotels in a specific city/location.
       - Examples: "Find me a hotel in London", "Show me places to stay in Paris", "Hotels in Tokyo".
       
    2. filter_by_stars
       - Description: User explicitly filters by star rating (luxury level).
       - Examples: "I want a 5 star hotel", "Show me 3-star budget options", "Find 4 star accommodation".

    3. top_rated_in_city
       - Description: User specifically asks for the "best", "top rated", or "highest ranked" hotels within a specific city.
       - Examples: "What are the best hotels in London?", "Top rated places in Paris", "Highest rated hotels in Dubai", "Best hotel in Cairo".

    4. hidden_gems
       - Description: User asks for hotels that have a LOW official star rating (e.g., 2 or 3 stars) but HIGH user review ratings.
       - Examples: "Find me a hidden gem", "Low star hotels with great reviews", "Underrated places to stay".
       
    5. best_for_traveller_type
       - Description: User asks for recommendations based on social group (Solo, Couple, Family, Business).
       - Examples: "Where should a solo traveller stay?", "Best hotels for couples", "Family friendly hotels", "Business trip recommendations".
       
    6. popular_with_nationality
       - Description: User asks where people from a specific country usually stay (social proof).
       - Examples: "Where do Egyptians usually stay?", "Hotels popular with French tourists", "Where do people from the UK go?".
       
    7. top_rated_by_attribute
       - Description: User asks for hotels excelling in specific qualities like Cleanliness, Location, Staff, etc.
       - Examples: "Which hotel has the best staff?", "Cleanest hotels", "Most comfortable beds", "Best location score".
       
    8. check_visa
       - Description: User asks about visa requirements between two specific countries.
       - Examples: "Do I need a visa from Egypt to France?", "Visa requirements for Japan from USA", "Can I travel to Italy without a visa?".
       
    9. compare_hotels
       - Description: User wants to compare two specific hotels side-by-side.
       - Examples: "Compare The Azure Tower and Marina Bay Zenith", "Difference between Hotel A and Hotel B", "Which is better: Hotel X or Hotel Y?".
       
    10. hotel_details
        - Description: User asks for specific details about ONE hotel by name.
        - Examples: "Tell me about The Golden Oasis", "Details for The Savannah House", "Give me info on Hotel X".
    
    11. unrecognized_intent
        - Description: The input is gibberish, off-topic, or does not fit ANY of the above categories.
        - Examples: "Hello", "How are you?", "What is the weather?", "asdfghjkl", "I like pizza".
    
    OUTPUT FORMAT:
    Return ONLY the intent label. Do not add explanations, punctuation, or extra text.
    """
    
    # Combine instructions with user input
    full_prompt = f"{system_prompt}\n\nUser Input: '{user_text}'\nIntent:"
    
    try:
        response = model.generate_content(full_prompt)
        return response.text.strip()
    except Exception as e:
        return f"Error: {e}"


# this function will extract the entities from the user input based on the intent classified in the previous function
def extract_entities(user_text, intent, kb):
    """
    Step 2: Extract specific parameters using the Knowledge Base (kb) for accuracy.
    """
    
    # Flatten lists for the prompt
    valid_cities = ", ".join(kb['cities'])
    valid_countries = ", ".join(kb['countries'])
    valid_hotels = ", ".join(kb['hotels'])
    
    system_prompt = f"""
    You are an Entity Extractor for a Knowledge Graph.
    Your goal is to extract parameters from the user's text for the intent: "{intent}".
    
    CRITICAL: You must normalize extracted entities to match the VALID LISTS provided below.
    - If the user says "UK" but the list has "United Kingdom", output "United Kingdom".
    - If the user says "Azure Hotel" but the list has "The Azure Tower", output "The Azure Tower".

    LOCATION INFERENCE RULE:
    - If an intent requires a 'city' but the user provides a 'Country', you MUST map it to the major city/capital from that country found in the VALID CITIES list.
    - Example: "Hidden gems in UK" -> Output "London" (if London is in valid cities).
    - Example: "Hotels in Egypt" -> Output "Cairo" (if Cairo is in valid cities).
    
    VALID LISTS (Use these exact names):
    - Cities: [{valid_cities}]
    - Countries: [{valid_countries}]
    - Hotels: [{valid_hotels}]
    
    EXTRACTION RULES:
    
    1. search_by_city           -> Extract "city" (Must match a valid City).
    2. top_rated_in_city        -> Extract "city" (Must match a valid City).
    
    3. hidden_gems              -> Extract "city" (Must match a valid City).
                                   * "Hidden gems" requires a specific location.
                                   * If the user says "Find hidden gems" without a city, return "city": null.
    
    4. filter_by_stars          -> Extract "stars" (integer, e.g., 5).
    
    5. best_for_traveller_type  -> Extract "traveller_type" (Value must be: Solo, Couple, Family, or Business).
    
    6. popular_with_nationality -> Extract "country" (Must match a valid Country).
    
    7. top_rated_by_attribute   -> Extract "attribute" (Value must be: cleanliness, location, staff, comfort, value_for_money).
                                   * Map synonyms: "hygiene"->"cleanliness", "price"->"value_for_money".
    
    8. check_visa               -> Extract "from_country" and "to_country" (Must match valid Countries).
    
    9. compare_hotels           -> Extract "hotel_1" and "hotel_2" (Must match valid Hotels).
    
    10. hotel_details           -> Extract "hotel_name" (Must match valid Hotel).

    11. unrecognized_intent     -> Return empty JSON {{}}.
    
    OUTPUT FORMAT: Return ONLY raw JSON.
    """
    
    full_prompt = f"{system_prompt}\n\nUser Input: '{user_text}'\nJSON Output:"
    
    try:
        response = model.generate_content(full_prompt)
        clean_text = response.text.strip()
        if clean_text.startswith("```"):
            clean_text = re.sub(r"^```json|^```|```$", "", clean_text, flags=re.MULTILINE).strip()
        return json.loads(clean_text)
    except Exception as e:
        return {"error": str(e)}

# this function generates the embedding vector of the input query using the specified embedder model
def get_input_query_embedding(user_text, embedder):
    try:
        vector = embedder.embed_query(user_text)
        return vector
    except Exception as e:
        print(f" Error generating embedding for user input query: {e}")
        return []
    
#========================================== Mikhail's Code END ==========================================
def setup_chroma_db(data, db_path):
    """
    Initializes ChromaDB and adds data in safe chunks.
    """
    if not data: return None

    print("\n--- Setting up ChromaDB ---")
    
    client = chromadb.PersistentClient(path=db_path) 
    collection = client.get_or_create_collection(name="hotel_collection")
    
    if collection.count() == 0:
        total_items = len(data['ids'])
        print(f"   Adding {total_items} documents to Chroma in batches...")
        
        batch_size = 5000 # Save 5000 at a time
        
        for i in range(0, total_items, batch_size):
            end = min(i + batch_size, total_items)
            print(f"   Saving items {i} to {end}...")
            
            collection.add(
                ids=data['ids'][i:end],
                embeddings=data['embeddings'][i:end],
                documents=data['documents'][i:end],
                metadatas=data['metadatas'][i:end]
            )
        print("   All data saved successfully.")
    else:
        print(f"   Database already has {collection.count()} items. Skipping insert.")
        
    return collection

def generate_chroma_data_chunked(embedder):
    """
    OPTIMIZED: Generates embeddings in BATCHES to handle 50k+ rows fast.
    """
    documents = []
    metadatas = []
    ids = []
    embeddings = []

    # =========================================================
    # PART 1: PREPARE TEXTS (Fast - Pure Python)
    # =========================================================
    print("--- 1. Preparing Data (Text Construction) ---")
    
    # --- Visa Data ---
    try:
        visa = pd.read_csv('/Users/hamzael-shammaa/dev/Lab_8/M3/visa.csv')
        print(f"   Processing {len(visa)} visa rules...")
        for _, row in visa.iterrows():
            text = f"Visa Requirement from {row['from']} to {row['to']}: {row['requires_visa']}. Visa Type: {row['visa_type']}."
            ids.append(f"visa_{row['from']}_{row['to']}")
            documents.append(text)
            metadatas.append({"doc_type": "visa"})
    except Exception as e: print(f"Visa Error: {e}")

    # --- Review Data ---
    try:
        hotels = pd.read_csv('/Users/hamzael-shammaa/dev/Lab_8/M3/hotels.csv')
        reviews = pd.read_csv('/Users/hamzael-shammaa/dev/Lab_8/M3/reviews.csv') # Reads full dataset
        users = pd.read_csv('/Users/hamzael-shammaa/dev/Lab_8/M3/users.csv')
        
        # Merge
        rev_full = pd.merge(reviews, users, on='user_id', how='left')
        master = pd.merge(rev_full, hotels, on='hotel_id', how='left')
        
        print(f"   Processing {len(master)} reviews (Text Only)...")
        
        for index, row in master.iterrows():
            # Clean Data
            user_type = row['traveller_type'] if pd.notnull(row['traveller_type']) else "Guest"
            user_origin = row['country_x'] if pd.notnull(row['country_x']) else "Unknown"
            review_text = str(row['review_text']).strip()
            def fmt(val): return f"{float(val):.1f}" if pd.notnull(val) else "N/A"
            
            # Construct Text
            text = (
                f"Hotel: {row['hotel_name']}\n"
                f"Location: {row['city']}, {row['country_y']}\n"
                f"Stars: {row['star_rating']}\n\n"
                
                f"--- HOTEL REPUTATION (Avg Base Scores) ---\n"
                f"Cleanliness: {fmt(row['cleanliness_base'])}\n"
                f"Comfort: {fmt(row['comfort_base'])}\n"
                f"Facilities: {fmt(row['facilities_base'])}\n"
                f"Location: {fmt(row['location_base'])}\n"
                f"Staff: {fmt(row['staff_base'])}\n"
                f"Value: {fmt(row['value_for_money_base'])}\n\n"
                
                f"--- THIS USER'S EXPERIENCE (Review Scores) ---\n"
                f"Reviewer: {user_type} from {user_origin}\n"
                f"Cleanliness: {fmt(row['score_cleanliness'])}\n"
                f"Comfort: {fmt(row['score_comfort'])}\n"
                f"Facilities: {fmt(row['score_facilities'])}\n"
                f"Location: {fmt(row['score_location'])}\n"
                f"Staff: {fmt(row['score_staff'])}\n"
                f"Value: {fmt(row['score_value_for_money'])}\n"
                f"Overall Rating: {fmt(row['score_overall'])}/10\n\n"
                
                f"Feedback: \"{review_text}\""
                )

            
            ids.append(f"review_{row['review_id']}")
            documents.append(text)
            metadatas.append({
                "doc_type": "review",
                "hotel_name": row['hotel_name'],
                "city": row['city'],
                "country": row['country_y'],
                "reviewer_origin": user_origin
            })
            
    except Exception as e:
        print(f"   Error processing CSVs: {e}")
        return None

    # =========================================================
    # PART 2: BATCH EMBEDDING (The Speed Fix)
    # =========================================================
    total_docs = len(documents)
    print(f"\n--- 2. Generating Embeddings for {total_docs} items ---")
    
    # Process 512 items at once
    batch_size = 512 
    
    for i in range(0, total_docs, batch_size):
        # Create a slice (chunk) of texts
        batch_texts = documents[i : i + batch_size]
        
        # Simple progress indicator so you know it's not frozen
        print(f"   🔹 Embedding batch {i} to {min(i + batch_size, total_docs)}...")
        
        # KEY CHANGE: embed_documents takes a LIST, not a single string
        batch_embeddings = embedder.embed_documents(batch_texts)
        embeddings.extend(batch_embeddings)

    print(f"✅ Generated {len(embeddings)} vectors.")
    
    return {
        "ids": ids,
        "embeddings": embeddings,
        "documents": documents,
        "metadatas": metadatas
    }

def search_chroma(user_input, embedder, collection, doc_filter=None):
    """
    Searches ChromaDB with an optional metadata filter.
    Example doc_filter: {"doc_type": "visa"} or {"doc_type": "review"}
    """
    try:
        # 1. Generate Query Vector
        query_vector = embedder.embed_query(user_input)
        
        # 2. Search with Filter (The 'where' parameter is the key!)
        results = collection.query(
            query_embeddings=[query_vector],
            n_results=5,
            where=doc_filter  # <--- THIS ENFORCES THE FILTER
        )
        
        formatted_results = []
        
        if not results['ids'][0]:
            return {"retrieval_method": "Chroma Vector Search", "results": []}

        # Chroma returns lists of lists (one list per query), so we access [0]
        ids = results['ids'][0]
        metas = results['metadatas'][0]
        docs = results['documents'][0]
        distances = results['distances'][0]
        
        for i in range(len(ids)):
            meta = metas[i]
            doc_text = docs[i]
            
            # CASE A: It's a Visa Rule
            if meta.get('doc_type') == 'visa':
                formatted_results.append({
                    "Type": "Visa Rule",
                    "Context": doc_text,
                    "Score": 1 - distances[i]
                })
                
            # CASE B: It's a Hotel Review
            elif meta.get('doc_type') == 'review':
                formatted_results.append({
                    "Type": "Hotel Review",
                    "Hotel": meta.get('hotel_name', 'Unknown'),
                    "City": meta.get('city', 'Unknown'),
                    "Context": doc_text,
                    "Score": 1 - distances[i]
                })
            else:
                formatted_results.append({"Type": "Unknown", "Context": doc_text})

        return {
            "retrieval_method": "Chroma Vector Search", 
            "results": formatted_results
        }
        
    except Exception as e:
        return {"error": f"Chroma Search Failed: {str(e)}"}
    

# Baseline Retrieval Model
def get_cypher_query(intent, entities):
    """
    Map intent to cypher query template.
    Returns query string and parameters dict.
    """
    query = None
    params = {}

    # 1. Search by City
    if intent == "search_by_city":
        query = """
        MATCH (h:Hotel)-[:LOCATED_IN]->(c:City)
        WHERE toLower(c.name) CONTAINS toLower($city)
        RETURN h.name as Name, h.star_rating as Stars, h.average_reviews_score as Rating
        ORDER BY h.average_reviews_score DESC
        """
        params = {"city": entities.get("city")}
    
    # 2. Filter by Stars
    elif intent == "filter_by_stars":
        query = """
        MATCH (h:Hotel)
        WHERE h.star_rating = $stars
        RETURN h.name as Name, h.star_rating as Stars, h.average_reviews_score as Rating
        ORDER BY h.average_reviews_score DESC
        """
        params = {"stars": entities.get("stars")}
    
    # 3. Top Rated in City
    elif intent == "top_rated_in_city":
        query = """
        MATCH (h:Hotel)-[:LOCATED_IN]->(c:City)
        WHERE toLower(c.name) CONTAINS toLower($city)
        RETURN h.name as Name, h.star_rating as Stars, h.average_reviews_score as Rating
        ORDER BY h.average_reviews_score DESC LIMIT 5
        """
        params = {"city": entities.get("city")}
    
    # 4. Hidden Gems
    # Add 1 Record to return answer from this query
    elif intent == "hidden_gems":
        query = """
        MATCH (h:Hotel)-[:LOCATED_IN]->(c:City)
        WHERE toLower(c.name) CONTAINS toLower($city)
        AND h.average_reviews_score >= 8.5 AND h.star_rating <= 3
        RETURN h.name as Name, h.star_rating as Stars, h.average_reviews_score as Rating
        ORDER BY h.average_reviews_score DESC
        """
        params = {"city": entities.get("city")}
    
    # 5. Best for Traveller Type
    elif intent == "best_for_traveller_type":
        query = """
        MATCH (t:Traveller {type: $traveller_type})-[:WROTE]->(r:Review)-[:REVIEWED]->(h:Hotel)
        WITH h, avg(r.score_overall) as type_rating, count(r) as num_reviews
        WHERE num_reviews >= 5
        RETURN h.name as Name, type_rating as Rating
        ORDER BY type_rating DESC
        """
        params = {"traveller_type": entities.get("traveller_type")}

    # 6. Popular with nationality
    elif intent == "popular_with_nationality":
        query = """
        MATCH (t:Traveller)-[:FROM_COUNTRY]->(c:Country {name: $country})
        MATCH (t)-[:STAYED_AT]->(h:Hotel)
        RETURN h.name as Name, count(t) as Visitors
        ORDER BY Visitors DESC
        """
        params = {"country": entities.get("country")}

    # 7. Top Rated by Attribute
    elif intent == "top_rated_by_attribute":
        attribute_map = {
            "cleanliness": "r.score_cleanliness",
            "location": "r.score_location",
            "staff": "r.score_staff",
            "comfort": "r.score_comfort",
            "value_for_money": "r.score_value_for_money",
            "facilities" : "r.score_facilities"
        }
        prop = attribute_map.get(entities.get('attribute'), "h.average_reviews_score")

        query = f"""
        MATCH (r:Review)-[:REVIEWED]->(h:Hotel)
        WITH h, avg({prop}) as avg_score, count(r) as num_reviews
        WHERE num_reviews >=5 
        RETURN h.name as Name, avg_score as Score, num_reviews as Reviews
        ORDER BY Score DESC
        """
        params = {}
    # 8. Check Visa
    elif intent == "check_visa":
        query = """
        MATCH (c1:Country {name: $from_country})
        MATCH (c2:Country {name: $to_country})
        OPTIONAL MATCH (c1)-[v:NEEDS_VISA]->(c2)
        RETURN c1.name as Origin, c2.name as Destination,
                CASE WHEN v IS NOT NULL THEN 'Visa Required: ' + v.visa_type ELSE 'No Visa Required' END as Status
        """
        params = {
            "from_country": entities.get("from_country"),
            "to_country": entities.get("to_country")
        }

    # 9. Compare Hotels
    elif intent == "compare_hotels":
        query = """
        MATCH (h:Hotel)
        WHERE h.name IN [$hotel_1, $hotel_2]
        RETURN h.name as Name, h.star_rating as Stars, h.average_reviews_score as Rating,
                h.cleanliness_base as Cleanliness, h.comfort_base as Comfort, h.facilities_base as Facilities
        """
        params = {
            "hotel_1": entities.get("hotel_1"),
            "hotel_2": entities.get("hotel_2")
        }
    # 10. Hotel Details
    elif intent == "hotel_details":
        query = """
        MATCH (h:Hotel {name: $hotel_name})
        RETURN h.name as Name, h.star_rating as Stars,
                h.average_reviews_score as Rating, h.cleanliness_base as Cleanliness, h.comfort_base as Comfort, h.facilities_base as Facilities
        """
        params = {"hotel_name": entities.get("hotel_name")}
    return query, params

# Handle passing query and params to LLM Layer
def execute_retrieval(driver, query, params):
    if not query: return {"error": "No query generated."}
    with driver.session() as session:
        try:
            result = session.run(query, params)
            return {
                "retrieval_method": "Baseline Cypher Query",
                "cypher_query": query,
                "context_data": [dict(r) for r in result]
            }
        except Exception as e:
            return {"error": str(e)}


# ==========================================
# MAZ AND HAMZA EXTRA FUNCTIONS

def input_to_KG( user_input, embedding_model_choice , retrieval_choice ):

    KG = {
        "cypher_query": "",
        "cypher_query_answer": "",
        "embedding_answer": ""
    }
    

    if embedding_model_choice == 'all-mpnet-base-v2':
        embedder = HuggingFaceEmbeddings(model_name="all-mpnet-base-v2")
        model_name_log = "MPNet-Base"
        current_db_path = "./chroma_db_mpnet"
    else:
        embedder = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        model_name_log = "MiniLM-L6"
        current_db_path = "./chroma_db_minilm"
        
    print(f"embedding model Loaded successfuly: {model_name_log}")

    # --- 2. CONNECT TO NEO4J ---
    print("\n--- Connecting to Database... ---")
    config = {}
    try:
        with open('config.txt', 'r') as f:
            for line in f:
                if '=' in line: k, v = line.strip().split('=', 1); config[k] = v.strip()
    except: print("Config missing"); exit()
                
    driver = GraphDatabase.driver(config['URI'], auth=(config['USERNAME'], config['PASSWORD']))
    
    # --- 3. LOAD KNOWLEDGE BASE ---
    print("--- Loading Knowledge Base (Grounding)... ---")
    knowledge_base = fetch_knowledge_base(driver)
    
    # --- 4. SETUP CHROMADB (With Caching Check) ---
    print("\n--- Checking Vector Database ---")
    # Initialize client to check if data exists
    client = chromadb.PersistentClient(path=current_db_path)
    chroma_collection = client.get_or_create_collection(name="hotel_collection")
    
    if chroma_collection.count() == 0:
        print("   📉 Database empty. Generating new embeddings (Chunking Strategy)...")
        # B. Generate Vectors (Using the CHUNKED function)
        vector_data = generate_chroma_data_chunked(embedder)
        # C. Save to ChromaDB
        setup_chroma_db(vector_data, current_db_path)
        # Re-get collection to ensure it's loaded
        chroma_collection = client.get_collection(name="hotel_collection")
    else:
        print(f"   ✅ Database loaded from disk ({chroma_collection.count()} documents). Skipping generation.")
    
    

    

        
    # A. Preprocessing
    print("   Thinking...")
    intent = classify_intent(user_input)
    print(f"   🔹 [Intent]: {intent}")
    
    if intent == "unrecognized_intent":
        print(" I didn't understand that. Try asking about hotels, visas, or reviews.")


        return KG
        
        
    entities = extract_entities(user_input, intent, knowledge_base)
    print(f"   🔸 [Entities]: {json.dumps(entities)}")
    
    final_context = {}

    mode = retrieval_choice
    
    # --- EXECUTE BASELINE (Always runs for both 1 and 2) ---

    if mode == "Cypher Only" or mode == "Hybrid" :
        print("   🔍 [Step 1] Running Baseline Cypher...")

        baseline_start = time.time()

        query, params = get_cypher_query(intent, entities)
        baseline_result = execute_retrieval(driver, query, params)

        baseline_end = time.time()
        baseline_duration = baseline_end - baseline_start
        baseline_result["latency"] = f"{baseline_duration:.4f} seconds"
        final_context["baseline"] = baseline_result

        # ensure KG exists and store the cypher query
        if 'KG' not in locals():
            KG = {}
        KG["cypher_query"] = baseline_result.get("cypher_query", "")

        # Format the cypher context_data into a plain-text string for LLM consumption
        context_data = baseline_result.get("context_data", []) or []
        KG["cypher_query_answer"] = format_context_data_for_llm(context_data)

        print(f" Basedline completed in {baseline_duration:.4f} seconds.")

    # --- EXECUTE VECTOR (Only for Hybrid) ---
    if  mode == 'Embeddings Only' or mode == 'Hybrid':
        print("   🧠 [Step 2] Running Chroma Vector Search...")
        target_filter = None
        if intent == "check_visa":
            print("Filtering for visa rules only.")
            target_filter = {"doc_type": "visa"}
        else:
            print("Filtering for reviews only.")
            target_filter = {"doc_type": "review"}
        vector_start = time.time()
        # Using the updated search_chroma function
        vector_result = search_chroma(user_input, embedder, chroma_collection, doc_filter=target_filter)
        vector_end = time.time()
        vector_duration = vector_end - vector_start
        vector_result["latency"] = f"{vector_duration:.4f} seconds"
        final_context["vector"] = vector_result
        final_context["pipeline"] = "Hybrid"
        KG["embedding_answer"] = format_vector_results_for_llm(vector_result.get("results", []))
        print(f"   Vector search completed in {vector_duration:.4f} seconds.")
    else:
        final_context["pipeline"] = "Baseline Only"


    driver.close()

    return KG


def format_vector_results_for_llm(results):

    """
    Convert Chroma vector search results into a concise plain-text string for LLM prompts.
    Expected item shapes: {"Type": "Hotel Review", "Hotel":..., "City":..., "Context":..., "Score":...}
    or {"Type": "Visa Rule", "Context":..., "Score":...}
    """
    if not results:
        return "Vector Results: No results."

    summaries = []
    for item in results:
        if not isinstance(item, dict):
            summaries.append(str(item))
            continue

        t = item.get('Type', '').lower()
        if 'hotel review' in t:
            hotel = item.get('Hotel', 'Unknown')
            city = item.get('City', 'Unknown')
            score = item.get('Score')
            context = item.get('Context', '')
            short_ctx = (context[:200] + '...') if isinstance(context, str) and len(context) > 200 else context
            summaries.append(f"Hotel: {hotel} | City: {city} | Score: {score} | {short_ctx}")
            continue

        if 'visa' in t:
            context = item.get('Context', '')
            summaries.append(f"Visa Rule: {context}")
            continue

        # Fallback: include type, score, and a short context
        score = item.get('Score')
        context = item.get('Context', '')
        short_ctx = (context[:200] + '...') if isinstance(context, str) and len(context) > 200 else context
        summaries.append(f"{item.get('Type', 'Result')} | Score: {score} | {short_ctx}")

    return "Vector Results (top {}):\n- ".format(len(summaries)) + "\n- ".join(summaries)


def format_context_data_for_llm(context_data):
    """
    Convert a list of context dicts into a concise plain-text string suitable for LLM prompts.
    Picks top_k items and formats common shapes (hotel rows, visa rows) into short lines.
    """
    if not context_data:
        return "Cypher Results: No results."

    # Respect top_k when set; if top_k is None, include all items
    items = context_data 

    summaries = []
    for idx, item in enumerate(items, start=1):
        if isinstance(item, dict):
            # Include all returned features (all keys) in a single line, truncating long values
            kvs = []
            for k, v in item.items():
                # Truncate long strings for readability
                if isinstance(v, str) and len(v) > 300:
                    v_str = v[:300] + '...'
                else:
                    v_str = v
                kvs.append(f"{k}: {v_str}")
            summaries.append(f"Result {idx}: " + " | ".join(kvs))
        else:
            summaries.append(f"Result {idx}: {str(item)}")

    return "Cypher Results (top {}):\n- ".format(len(summaries)) + "\n- ".join(summaries)
# ==========================================
# we will test if the app is working here 
if __name__ == "__main__":
    
    # --- 1. EMBEDDING MODEL SELECTION ---
    print("\n" + "="*50)
    print("EMBEDDING SETUP")
    print("="*50)
    print("Choose your Embedding Model:")
    print("1. MiniLM-L6 (Fast)")
    print("2. MPNet-Base (Accurate)")
    

    # TODO: Needs to be remoevd and use the one in the UI 
    choice = input("\nEnter choice (1 or 2): ").strip()
    
    print("\n Loading selected embedding model...")
    if choice == '2':
        embedder = HuggingFaceEmbeddings(model_name="all-mpnet-base-v2")
        model_name_log = "MPNet-Base"
        current_db_path = "./chroma_db_mpnet"
    else:
        embedder = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        model_name_log = "MiniLM-L6"
        current_db_path = "./chroma_db_minilm"
        
    print(f"model Loaded successfuly: {model_name_log}")

    # --- 2. CONNECT TO NEO4J ---
    print("\n--- Connecting to Database... ---")
    config = {}
    try:
        with open('/Users/hamzael-shammaa/dev/Lab_8/M3/config.txt', 'r') as f:
            for line in f:
                if '=' in line: k, v = line.strip().split('=', 1); config[k] = v.strip()
    except: print("Config missing"); exit()
                
    driver = GraphDatabase.driver(config['URI'], auth=(config['USERNAME'], config['PASSWORD']))
    
    # --- 3. LOAD KNOWLEDGE BASE ---
    print("--- Loading Knowledge Base (Grounding)... ---")
    knowledge_base = fetch_knowledge_base(driver)
    
    # --- 4. SETUP CHROMADB (With Caching Check) ---
    print("\n--- Checking Vector Database ---")
    # Initialize client to check if data exists
    client = chromadb.PersistentClient(path=current_db_path)
    chroma_collection = client.get_or_create_collection(name="hotel_collection")
    
    if chroma_collection.count() == 0:
        print("   📉 Database empty. Generating new embeddings (Chunking Strategy)...")
        # B. Generate Vectors (Using the CHUNKED function)
        vector_data = generate_chroma_data_chunked(embedder)
        # C. Save to ChromaDB
        setup_chroma_db(vector_data, current_db_path)
        # Re-get collection to ensure it's loaded
        chroma_collection = client.get_collection(name="hotel_collection")
    else:
        print(f"   Database loaded from disk ({chroma_collection.count()} documents). Skipping generation.")
    
    # --- 5. START CHAT ---
    print("\n" + "="*60)
    print(f" HOTEL ASSISTANT (Running with {model_name_log})")
    print("Type 'exit' to stop.")
    print("="*60 + "\n")
    
    while True:
        user_input = input("You: ").strip()
        if user_input.lower() in ['exit', 'quit']: 
            print("Goodbye!")
            break
        if not user_input: continue
            
        # A. Preprocessing
        print("   Thinking...")
        intent = classify_intent(user_input)
        print(f"   [Intent]: {intent}")
        
        if intent == "unrecognized_intent":
            print("   I didn't understand that. Try asking about hotels, visas, or reviews.")
            continue
            
        entities = extract_entities(user_input, intent, knowledge_base)
        print(f"   [Entities]: {json.dumps(entities)}")
        
        final_context = {}

        # B. Pipeline Selection
        print("\n   [Select Retrieval Mode]")
        mode = input("   (1) Baseline Only   (2) Hybrid (Baseline + Vector): ").strip()
        
        # --- EXECUTE BASELINE (Always runs for both 1 and 2) ---
        print("   🔍 [Step 1] Running Baseline Cypher...")

        baseline_start = time.time()

        query, params = get_cypher_query(intent, entities)
        baseline_result = execute_retrieval(driver, query, params)

        baseline_end = time.time()
        baseline_duration = baseline_end - baseline_start
        baseline_result["latency"] = f"{baseline_duration:.4f} seconds"
        final_context["baseline"] = baseline_result

        print(f"   Baseline completed in {baseline_duration:.4f} seconds.")

        # --- EXECUTE VECTOR (Only for Hybrid) ---
        if mode == '2':
            print("   [Step 2] Running Chroma Vector Search...")
            target_filter = None
            if intent == "check_visa":
                print("Filtering for visa rules only.")
                target_filter = {"doc_type": "visa"}
            else:
                print("Filtering for reviews only.")
                target_filter = {"doc_type": "review"}
            vector_start = time.time()
            # Using the updated search_chroma function
            vector_result = search_chroma(user_input, embedder, chroma_collection, doc_filter=target_filter)
            vector_end = time.time()
            vector_duration = vector_end - vector_start
            vector_result["latency"] = f"{vector_duration:.4f} seconds"
            final_context["vector"] = vector_result
            final_context["pipeline"] = "Hybrid"
            print(f"   Vector search completed in {vector_duration:.4f} seconds.")
        else:
            final_context["pipeline"] = "Baseline Only"

        # D. Output for LLM (Simulated)
        print("\n" + "-"*20 + " FINAL RETRIEVED CONTEXT " + "-"*20)
        # We limit the output preview so it doesn't flood the console
        print(json.dumps(final_context, indent=2))#[:2000] + "...") 
        print("-" * 55 + "\n")

