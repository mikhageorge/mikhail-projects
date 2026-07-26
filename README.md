ACL 3 EVENT TICKETING SCALABLE PLATFORM :
High-Level System Architecture
The Event Ticketing Scalable Project is designed as a distributed, cloud-native microservices application developed using Java and Maven. It employs an API Gateway pattern to route external traffic and relies on an event-driven architecture for inter-service communication, ensuring loose coupling and high scalability. The system is divided into five core domain microservices and a central gateway. The API Gateway serves as the single entry point, handling request routing and global security measures like JWT validation. The User Service manages registration, authentication, profiles, activity feeds, and user-specific data such as favorite venues. The Event Service handles the core event catalog, event sessions, capacity tracking, and advanced event searching mechanisms. The Booking Service manages the reservation lifecycle, booking cost estimations, attendance tracking, and user-to-event relationships. The Ticket Service is responsible for ticket generation, ticket scanning validations, and tracking unused or nearby tickets. Finally, the Sales Service processes financial transactions, applies promotional discounts, calculates tier revenue, and handles complex refund strategies.
Polyglot Persistence Data Architecture
The project demonstrates advanced data engineering by utilizing polyglot persistence, matching specific database technologies to the appropriate microservice use case. PostgreSQL acts as the primary transactional datastore, with each service maintaining its own isolated database to ensure data autonomy. MongoDB is utilized across multiple services for flexible document storage, specifically for auditing and logging events. Cassandra is implemented within the Ticket Service to handle high-velocity, append-heavy data such as real-time ticket scanning logs. Neo4j is used within the Booking Service to map and traverse complex relationships, specifically tracking users, events, and their connections. Elasticsearch is integrated into the Event Service to provide fast, full-text search capabilities across the event catalog. Additionally, Redis is deployed for high-speed data access and caching across all services.
Asynchronous Communication & Messaging
To maintain data consistency and decouple services, the architecture heavily leverages message brokers and asynchronous messaging patterns. RabbitMQ acts as the central message broker, with services containing dedicated messaging packages for localized publishers and consumers. The system implements the Saga pattern to maintain eventual consistency across multiple services during complex distributed transactions, such as completing a ticket sale and generating the corresponding ticket. Services also utilize the Observer pattern for internal event observation to trigger local domain events before publishing them to the wider message bus. For synchronous inter-service communication, the system relies on OpenFeign clients defined in a shared contracts module
Security Implementation
Security is enforced consistently across the platform using token-based authentication. JSON Web Tokens (JWT) and role-based authorization are handled via custom filters and authorization handlers built into the system. Each microservice implements secure context management and token extraction handlers to securely resolve user identity and roles from incoming requests passed through the API Gateway
Infrastructure, Orchestration & DevOps
The entire system is fully containerized and orchestrated, designed for seamless cloud deployment. Every microservice includes a Dockerfile for containerization, and the repository features a comprehensive Kubernetes configuration directory for a production-ready cluster architecture. This Kubernetes setup includes Deployments and Services for stateless microservices, alongside StatefulSets and Persistent Volume Claims (PVCs) for all stateful database workloads to ensure data persistence. ConfigMaps and Secrets are also heavily utilized for injecting environment configurations and managing sensitive credentials.
Observability & Monitoring
A comprehensive observability stack is deployed within a dedicated monitoring Kubernetes namespace to ensure system health and visibility. Prometheus is deployed to scrape and aggregate system metrics, while Grafana provides extensive data visualization. The repository includes specific, pre-built JSON dashboards for every domain to monitor service health and business metrics effectively. Furthermore, Loki is deployed for centralized log aggregation across the highly distributed system.

Adversarial Search AI Battle Agent :
• Developed an adversarial AI agent in Java using Minimax and Alpha-Beta pruning algorithms to determine
optimal game strategies, successfully optimizing search efficiency and maximizing win utility in a turn-based
battle simulation.

Traveling AI assistant
This project was divided into 3 milestones :
Milestone 1 :
• Data Pipeline & Engineering: Aggregated and cleaned hotels, users, and reviews datasets to derive traveler
insights and engineer a country_group target variable for regional classification.
• Modeling & Explainability: Developed predictive models (using Logistic Regression and Neural Networks)
to classify hotel regions, implementing XAI techniques like LIME and SHAP to interpret model decisions and
feature importance and finally chose the best model for our use case.
Milestone 2 :
• Knowledge Graph Architecture: Architected and populated a Neo4j Knowledge Graph to model semantic
relationships between travelers, hotels, and visa policies, transforming tabular data into a graph structure with
strict uniqueness constraints.
• Graph Analytics: Engineered complex Cypher queries to extract demographic insights and implemented
rule-based logic to quantify hotel performance gaps, specifically identifying properties that statistically "exceed
expectations".
Milestone 3 :
• Hybrid Graph-RAG Pipeline: Engineered an end-to-end Retrieval-Augmented Generation (RAG) system
merging Neo4j graph traversals with ChromaDB vector search to ground LLM responses in factual hotel and
visa data.
• Interactive UI & Explainability: Deployed a Streamlit chat interface featuring intent classification to route
queries and a "glass-box"debug dashboard to visualize retrieved graph context and monitor system latency.


Chess game engine
• the chess game included functions to initialize a chess board, visualize the chess board, move a piece according
to its movement rules, and suggest possible legal moves for any piece on the board.
• The project was implemented using Haskell

Labs scheduling system :
• A system was developed to allocate weekly lab sessions of a course to available TAs. Each lab was assigned
precisely one TA, and each TA had a specified teaching load, representing the number of labs they needed to
teach per week. The system ensured that no TA was assigned more labs than their teaching load, though they
could be assigned fewer. Additionally, the system restricted the number of slots assigned to each TA per day
to a specified limit.
• The project was implemented using Prolog

A donation application for NGO :
• In milestone 1 , we were asked to write 150 consistent and complete functional and non-functional user stories
to cover the functionalities that should be provided by the application .
• In milestone 2 , A complete front-end was implemented for the application but with user stories provided to us
by the course instructor .
• Milestone 2 was implemented using CSS , HTML5 and JavaScript .

Database and web application for a student advising system : 
• The implemented database system accommodates Admins, Advisors, and Advising Students, each with specific
roles and permissions. Admins modify system information and handle requests. Advisors create and edit
graduation plans for students with over 157 credit hours, with each student assigned one advisor per semester,
though advisors can manage multiple students. Students can request extra credit hours or courses if not on
probation, limited to 3 credit hours while staying below 34 total credit hours, with each additional hour costing
1000 LE added to the next payment due. They can also register for makeup exams, with all students eligible for
the first makeup, and second makeup eligibility limited to those who failed or missed the first and have no more
than 2 failed courses in odd or even semesters. Instructors are assigned to courses and slots , while payments
can be divided into installments.
• a full schema was made in milestone 1 of this project , the database engine was implemented in milestone 2
using SQL . a front-end was implemented in milestone 3 using ASP.NET forms.

Von Neumann architecture simulation :
• The project simulates a fictional processor design and architecture called "Fillet-O-Neumann with moves on the
side,"based on the Von Neumann design where data and instructions share the same memory. It supports three
instruction formats: R-type for register-to-register operations (arithmetic and logical), I-type for operations
with immediate values (loading, storing, branching, and immediate arithmetic/logical), and J-type for jump
instructions. The code implements the RISC pipeline logic through five stages: Fetch, Decode, Execute, Memory
Access, and Write-back, with stage logic varying based on the instruction type.
• The project was implemented using C

The last of us game
• Implemented a single player game for survival in a world filled with zombies using OOP concepts. the player
can choose to play with different characters and each character has a special action . players can only move
within a 15*15 grid and they may find traps on some cells that decrease the player’s health or supplies that
increase the player’s health or allow the player to use his special action. when the player kills a zombie , another
one will spawn on the map and the game doesn’t end except when the player collects and uses all vaccines (type
of supplies ) or when all the heroes are defeated by zombies.
• The game engine was implemented with java in milestone 1 and 2 of this project . the GUI for the game was
implemented in milestone 3 using javaFX

Operating system simulation :
• The project code simulates an operating system by implementing the round robin (RR) scheduling algorithm
to manage system processes. It includes creating an interpreter to read and execute code from text files,
implementing memory management to store processes, and using mutexes to ensure mutual exclusion over
critical resources.
• The project was implemented using C
