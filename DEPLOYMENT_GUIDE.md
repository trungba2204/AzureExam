# Hướng Dẫn Deploy Azure Function - BattleGame

## Tổng Quan
Tài liệu này hướng dẫn chi tiết cách deploy Azure Functions và Website lên Azure Cloud cho dự án BattleGame.

---

## Phần 1: Chuẩn Bị

### 1.1. Yêu Cầu Hệ Thống
- Azure Account (có thể tạo miễn phí tại: https://azure.microsoft.com/free/)
- .NET 6.0 SDK
- Azure Functions Core Tools v4
- Visual Studio Code hoặc Visual Studio 2022
- MySQL Server (local hoặc cloud)
- Node.js và npm (cho frontend)

### 1.2. Công Cụ Cần Cài Đặt

#### Azure CLI
```bash
# Windows (PowerShell)
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### Azure Functions Core Tools
```bash
# Windows
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# macOS
brew tap azure/functions
brew install azure-functions-core-tools@4

# Linux
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```

---

## Phần 2: Setup Database MySQL

### 2.1. Tạo Database Local (Test)
```bash
# Kết nối MySQL
mysql -u root -p

# Nhập password: 1234567890

# Chạy scripts
source /path/to/database/create_database.sql
source /path/to/database/stored_procedures.sql
```

### 2.2. Tạo MySQL Database Trên Azure

#### Bước 1: Tạo Azure Database for MySQL
```bash
# Login Azure
az login

# Tạo Resource Group
az group create --name battlegame-rg --location southeastasia

# Tạo MySQL Server
az mysql flexible-server create \
  --resource-group battlegame-rg \
  --name battlegame-mysql-server \
  --location southeastasia \
  --admin-user myadmin \
  --admin-password YourPassword123! \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 8.0.21 \
  --storage-size 20 \
  --public-access 0.0.0.0

# Cho phép Azure Services truy cập
az mysql flexible-server firewall-rule create \
  --resource-group battlegame-rg \
  --name battlegame-mysql-server \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

#### Bước 2: Import Database
```bash
# Kết nối MySQL trên Azure
mysql -h battlegame-mysql-server.mysql.database.azure.com \
      -u myadmin \
      -p

# Chạy scripts
source /path/to/database/create_database.sql
source /path/to/database/stored_procedures.sql
```

---

## Phần 3: Deploy Azure Functions

### 3.1. Build và Test Local

```bash
# Di chuyển vào thư mục azure-functions
cd azure-functions

# Restore packages
dotnet restore

# Build project
dotnet build

# Test local
func start
```

Kiểm tra APIs tại:
- `http://localhost:7071/api/registerplayer` (POST)
- `http://localhost:7071/api/createasset` (POST)
- `http://localhost:7071/api/getassetsbyplayer` (GET)

### 3.2. Deploy Lên Azure

#### Bước 1: Tạo Function App
```bash
# Tạo Storage Account
az storage account create \
  --name battlegamestorage \
  --resource-group battlegame-rg \
  --location southeastasia \
  --sku Standard_LRS

# Tạo Function App
az functionapp create \
  --resource-group battlegame-rg \
  --name battlegame-functions \
  --storage-account battlegamestorage \
  --consumption-plan-location southeastasia \
  --runtime dotnet-isolated \
  --runtime-version 6 \
  --functions-version 4 \
  --os-type Linux
```

#### Bước 2: Cấu Hình Connection String
```bash
# Set MySQL Connection String
az functionapp config appsettings set \
  --name battlegame-functions \
  --resource-group battlegame-rg \
  --settings MySqlConnectionString="Server=battlegame-mysql-server.mysql.database.azure.com;Database=BATTLEGAME;User=myadmin;Password=YourPassword123!;Port=3306;SslMode=Required;"
```

#### Bước 3: Deploy Code
```bash
# Deploy từ thư mục azure-functions
func azure functionapp publish battlegame-functions
```

#### Bước 4: Kiểm Tra Deployment
```bash
# Lấy URL của Function App
az functionapp show \
  --name battlegame-functions \
  --resource-group battlegame-rg \
  --query defaultHostName -o tsv
```

URL sẽ có dạng: `https://battlegame-functions.azurewebsites.net`

APIs:
- `https://battlegame-functions.azurewebsites.net/api/registerplayer`
- `https://battlegame-functions.azurewebsites.net/api/createasset`
- `https://battlegame-functions.azurewebsites.net/api/getassetsbyplayer`

---

## Phần 4: Deploy Frontend Website

### 4.1. Build Frontend

```bash
# Di chuyển vào thư mục frontend
cd frontend

# Cập nhật API URL trong src/config.js
# Thay YOUR-FUNCTION-APP bằng tên Function App của bạn
# API_BASE_URL: 'https://battlegame-functions.azurewebsites.net'

# Install dependencies
npm install

# Build production
npm run build
```

### 4.2. Deploy Lên Azure Static Web Apps

#### Bước 1: Tạo Static Web App
```bash
az staticwebapp create \
  --name battlegame-website \
  --resource-group battlegame-rg \
  --location southeastasia \
  --sku Free
```

#### Bước 2: Deploy
```bash
# Install Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Deploy
cd frontend
swa deploy build --app-name battlegame-website
```

### 4.3. Deploy Bằng Azure Portal (Phương Án Thay Thế)

1. Vào Azure Portal: https://portal.azure.com
2. Tạo **Static Web App**
3. Chọn **Deploy from local**
4. Upload thư mục `frontend/build`

---

## Phần 5: Test APIs

### 5.1. Test Bằng Postman hoặc cURL

#### API 1: Register Player
```bash
curl -X POST https://battlegame-functions.azurewebsites.net/api/registerplayer \
  -H "Content-Type: application/json" \
  -d '{
    "playerName": "Player1",
    "fullName": "Nguyen Van A",
    "age": "20",
    "level": 10,
    "email": "player1@example.com"
  }'
```

#### API 2: Create Asset
```bash
curl -X POST https://battlegame-functions.azurewebsites.net/api/createasset \
  -H "Content-Type: application/json" \
  -d '{
    "assetName": "Hero 1",
    "levelRequire": 1
  }'
```

#### API 3: Get Assets By Player
```bash
curl -X GET https://battlegame-functions.azurewebsites.net/api/getassetsbyplayer
```

### 5.2. Thêm Sample Data

```sql
-- Kết nối vào MySQL
mysql -h battlegame-mysql-server.mysql.database.azure.com -u myadmin -p

USE BATTLEGAME;

-- Thêm Players
CALL sp_RegisterPlayer('Player1', 'Nguyen Van A', '20', 10, 'player1@example.com');
CALL sp_RegisterPlayer('Player2', 'Tran Thi B', '19', 3, 'player2@example.com');
CALL sp_RegisterPlayer('Player3', 'Le Van C', '23', 10, 'player3@example.com');

-- Thêm Assets
CALL sp_CreateAsset('Hero 1', 1);
CALL sp_CreateAsset('Hero 2', 5);

-- Gán Assets cho Players
CALL sp_AssignAssetToPlayer('Player1', 'Hero 1');
CALL sp_AssignAssetToPlayer('Player2', 'Hero 2');
CALL sp_AssignAssetToPlayer('Player3', 'Hero 1');

-- Kiểm tra report
CALL sp_GetAssetsByPlayer();
```

---

## Phần 6: Troubleshooting

### 6.1. Lỗi Kết Nối Database
```bash
# Kiểm tra firewall rules
az mysql flexible-server firewall-rule list \
  --resource-group battlegame-rg \
  --name battlegame-mysql-server

# Thêm IP của bạn
az mysql flexible-server firewall-rule create \
  --resource-group battlegame-rg \
  --name battlegame-mysql-server \
  --rule-name AllowMyIP \
  --start-ip-address YOUR_IP \
  --end-ip-address YOUR_IP
```

### 6.2. Xem Logs
```bash
# Xem logs của Function App
az functionapp log tail \
  --name battlegame-functions \
  --resource-group battlegame-rg
```

### 6.3. CORS Issues
```bash
# Enable CORS cho Function App
az functionapp cors add \
  --name battlegame-functions \
  --resource-group battlegame-rg \
  --allowed-origins '*'
```

---

## Phần 7: Dọn Dẹp Resources (Nếu Cần)

```bash
# Xóa toàn bộ Resource Group
az group delete --name battlegame-rg --yes
```

---

## Tổng Kết

Sau khi hoàn thành các bước trên, bạn sẽ có:

1. ✅ MySQL Database trên Azure với đầy đủ tables và stored procedures
2. ✅ 3 Azure Functions APIs:
   - `registerplayer` - Đăng ký người chơi mới
   - `createasset` - Tạo asset mới
   - `getassetsbyplayer` - Lấy báo cáo assets của người chơi
3. ✅ Website React hiển thị báo cáo

**Function App URL**: `https://battlegame-functions.azurewebsites.net`  
**Website URL**: `https://battlegame-website.azurewebsites.net`

---

## Liên Hệ & Hỗ Trợ

Nếu có vấn đề trong quá trình deploy, vui lòng kiểm tra:
- Azure Portal logs
- Function App Application Insights
- MySQL connection string
- CORS settings

Good luck với bài thi SET01! 🚀

