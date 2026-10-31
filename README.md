Smart Supply Chain Tracking System
A supply chain management and tracking application built with
Flutter, Spring Boot, and MySQL. The project is designed to
connect suppliers, warehouses, customers, administrators, and delivery
users through a shared system for product management, inventory
visibility, order processing, and delivery tracking.
Project status: This README describes the features and
architecture discussed during development. Verify the current source
code, API routes, and deployment configuration before presenting every
feature as production-ready.

Table of Contents
- Overview
- Objectives
- Technology Stack
- Main Modules
- Key Workflows
- System Architecture
- Project Structure
- Prerequisites
- Getting Started
  - Backend Setup
  - Flutter Setup
- Configuration
- Maps and Location
- Docker Deployment
- Testing
- Security Notes
- Future Enhancements
- Contributing
- License
Overview
The Smart Supply Chain Tracking System helps manage the movement of
products from suppliers to warehouses and then to customers. It provides
role-based screens and backend services for product registration, stock
supply, inventory monitoring, customer ordering, and delivery-location
updates.

The Flutter application communicates with a Spring Boot REST API. The
backend applies business rules and stores application data in a MySQL
database.
Objectives
- Digitize supplier, warehouse, customer, administration, and delivery
  workflows.
- Maintain product and warehouse stock information.
- Allow suppliers to register products and supply stock to warehouses.
- Show customers products that have available inventory.
- Validate stock during order processing.
- Support delivery-location updates and map-based tracking.
- Provide barcode-based product lookup and basic inventory summaries.
Technology Stack
  Layer                   Technology              Purpose
  Frontend                Flutter / Dart          Mobile and web user
interface

  Backend                 Java, Spring Boot 3.3.x REST APIs and business
logic

  Database                MySQL                   Persistent application
data

  ORM                     Spring Data JPA /       Database access and
Hibernate               entity mapping

  Security                Spring Security, JWT    Authentication and
protected API access

  Maps                    flutter_map,          Map display and
latlong2,             location visualization
OpenStreetMap           

  Device location         geolocator            Device GPS access

  Backend build           Maven                   Dependency management
and packaging

  Source control          Git / GitHub            Version control and
collaboration
Optional                Docker / Docker Compose Local multi-service
containerization                                deployment
Main Modules
1. Admin
- Manage and monitor system operations.
- View product and inventory information.
- Review supplier stock-supply history.
- View available operational summaries and analytics supported by the
  backend.
2. Supplier
- Register a new product with its name, price, and optional barcode.
- Select a destination warehouse.
- Enter the quantity to supply.
- Submit stock-supply information for inventory recording.
3. Warehouse
- View warehouse-related inventory information.
- Monitor available product quantities.
- Support stock handling and fulfilment workflows implemented by the
  application.
4. Customer
- Browse the available product catalogue.
- View product and stock information returned by the backend.
- Place orders through the application.
- Follow delivery progress when tracking data is available.
5. Delivery
- Access delivery-related functionality.
- Share device GPS coordinates when location permission is granted.
- Support customer-facing delivery tracking through location updates.
Key Workflows
Supplier → Warehouse → Customer
1. The supplier enters a product name, price, and optional barcode.
2. The supplier selects a warehouse and enters the quantity.
3. The backend creates the product and records the stock-supply
   operation.
4. Warehouse inventory reflects the supplied stock.
5. The customer catalogue can display products with available stock.
6. The customer can place an order, subject to backend stock
   validation.
Order Processing
The backend is intended to validate available inventory during order
placement. Stock checks and order updates should be performed on the
server, using transactional database operations where required, to
reduce the risk of overselling.
Delivery Tracking
1. The delivery device obtains its location after the user grants
   permission.
2. The Flutter application sends location coordinates to the backend.
3. The backend stores location updates associated with the relevant
   delivery/order.
4. The customer tracking screen can display available location
   information on a map.
Barcode Lookup and Inventory Summary
The application includes barcode lookup functionality and a basic
seven-day run-rate estimate discussed during development. The run-rate
estimate is a simple calculation, not a trained machine-learning model.
System Architecture
+-------------------------------+
|       Flutter Application     |
| Admin | Supplier | Warehouse  |
| Customer | Delivery           |
+---------------+---------------+
                |
                | HTTP / JSON
                v
+-------------------------------+
|       Spring Boot REST API    |
| Controllers | Services        |
| Security / JWT | Repositories |
+---------------+---------------+
                |
                | JPA / Hibernate
                v
+-------------------------------+
|          MySQL Database       |
| Users | Products | Inventory  |
| Orders | Supply History       |
| Delivery Locations            |
+-------------------------------+
Project Structure
Place both projects inside one parent folder:
Smart-Supply-Chain/
├── smart_supply_chain_app/
│   ├── lib/
│   ├── web/
│   ├── pubspec.yaml
│   └── ...
│
├── smart-supply-chain-backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       └── resources/
│   ├── pom.xml
│   └── ...
│
├── README.md
└── .gitignore
The actual directory names in your repository may differ. Update the
commands below if you use different names.
Prerequisites
Install the following tools:
- Git
- Visual Studio Code
- Flutter SDK
- Java JDK compatible with the backend
  configuration (development logs showed Java 21)
- Maven or the Maven Wrapper if included
- MySQL Community Server
- Optional: Docker
  Desktop
Getting Started
Clone the repository:
git clone https://github.com/YOUR_USERNAME/Smart-Supply-Chain.git
cd Smart-Supply-Chain
Replace YOUR_USERNAME with the GitHub account that owns the
repository.
Backend Setup
1. Open a terminal in the backend directory:
   cd smart-supply-chain-backend
2. Create a MySQL database. For example:
   CREATE DATABASE smart_supply_chain;
3. Configure the database connection in
   src/main/resources/application.properties or through environment
   variables. Example values:
   spring.datasource.url=jdbc:mysql://localhost:3306/smart_supply_chain
   spring.datasource.username=YOUR_DB_USERNAME
   spring.datasource.password=YOUR_DB_PASSWORD
4. Configure the JWT signing secret using a secure local configuration
   or environment variable. Do not commit real secrets.
5. Start the backend:
   mvn spring-boot:run
The development configuration discussed for this project used port
8080. Confirm the active port in your configuration.
Flutter Setup
1. Open a second terminal in the Flutter directory:
   cd smart_supply_chain_app
2. Install dependencies:
   flutter pub get
3. Configure the API base URL for your target:
   - Android emulator: use the host address reachable from the
     emulator (commonly 10.0.2.2 for an Android Studio emulator).
   - Physical phone: use your development computer's LAN IP address,
     with both devices on the same network.
   - Flutter Web: use a browser-reachable API URL. If frontend and
     backend are on different origins, configure backend CORS
     appropriately.
4. Run on Chrome:
   flutter run -d chrome
5. Or run on a connected device:
   flutter devices
   flutter run -d <device_id>
Configuration
Before running the project, check the following configuration:
  Configuration           Where to check             Notes
  MySQL URL               Backend                    Use the correct host,
application.properties   port, and database name

  MySQL username/password Backend environment or     Never commit real
local config               credentials

  JWT secret              Backend security           Use a strong secret
configuration              stored outside Git

  API base URL            Flutter API                Must be reachable from
configuration/service      the selected
device/browser

  Location permission     Android/iOS app            Required for GPS
configuration and device   tracking
settings                   
Map tile source         Flutter map                Respect the selected
screen/configuration       tile provider's usage
policy
Maps and Location
The map implementation discussed for this project uses:
- flutter_map
- latlong2
- OpenStreetMap map tiles
- geolocator for device location
The standard OpenStreetMap tile endpoint is:
https://tile.openstreetmap.org/{z}/{x}/{y}.png
Display attribution to OpenStreetMap contributors in the application.
The public OpenStreetMap tile service is subject to a usage policy and
does not provide a guaranteed production service level. For high-traffic
production use, select a suitable tile provider or host tiles according
to the provider's terms.

Browser geolocation generally requires user permission and a secure
context (HTTPS or localhost).
Docker Deployment
Docker Compose can be used to run the backend, database, and optionally
the Flutter web frontend as separate services.

A typical container layout is:
  Service                             Purpose
  mysql                             MySQL database

  backend                           Spring Boot API
frontend                          Nginx serving the Flutter web build
and optionally proxying API
requests
Typical commands, once Dockerfiles and docker-compose.yml have been
configured for this repository:
docker compose up --build -d
docker compose ps
docker compose logs -f
docker compose down
Important deployment notes:
- Inside Docker Compose, the backend should connect to MySQL using the
  database service name (for example, mysql), not localhost.
- The Flutter web app must use a browser-accessible API URL or a
  configured reverse proxy.
- Keep .env files and secrets out of Git.
- Persist MySQL data using a Docker volume.
- Do not expose the database port publicly.
- Test the Docker configuration against the current source code before
  relying on it in production.
Testing
Recommended verification checklist:
- [ ] Valid and invalid login behaviour.
- [ ] Role-based access to protected APIs and screens.
- [ ] Supplier product creation and input validation.
- [ ] Supplier stock supply to the selected warehouse.
- [ ] Inventory quantity updates and supply-history records.
- [ ] Customer catalogue displays only products with available stock.
- [ ] Order placement rejects insufficient stock.
- [ ] Concurrent order requests do not oversell inventory.
- [ ] Barcode lookup for valid and unknown codes.
- [ ] GPS permission and location update handling.
- [ ] Customer delivery tracking displays available location
  information.
- [ ] Data remains available after application/container restart.
Security Notes
- Never commit database passwords, JWT secrets, access tokens, private
  keys, keystores, or production .env files.
- Use environment variables or a secrets manager for sensitive
  configuration.
- Keep protected APIs secured with authentication and authorization.
- Validate all important business rules on the backend; do not trust
  values supplied only by the Flutter client.
- Use HTTPS for public deployments.
- Restrict database access to the backend and trusted administration
  tools.
Future Enhancements
Possible future improvements include:
- Automated unit, integration, and API tests.
- Database schema migrations using Flyway or Liquibase.
- CI/CD pipeline for automated build and test.
- Production monitoring, structured logs, and health checks.
- Push notifications for order and delivery events.
- More detailed operational reports and configurable analytics.
- Production-grade map tile hosting/provider.
- Cloud deployment with HTTPS, managed database and secret storage.
Contributing
