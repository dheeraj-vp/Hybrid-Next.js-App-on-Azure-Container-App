# Deploying a Hybrid Next.js App on Azure Container Apps

### Create `.env.local` File  

The `.env.local` file stores sensitive environment variables needed for authentication and application configuration. Ensure this file is **not committed** to Git by adding it to `.gitignore`.  

```bash
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_YOUR_PUBLISHABLE_KEY
CLERK_SECRET_KEY=sk_live_YOUR_SECRET_KEY
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_FRONTEND_API_URL=https://clerk.YOUR_APP.eastus.azurecontainerapps.io
```

### Dockerfile
The Dockerfile defines how the Next.js application will be containerized.


## 🚀 Step 1: Log in to Azure & Set Variables

### 1.1 Log in to Azure CLI
This command will open a browser for authentication. Once logged in, return to the terminal.
```bash
az login
```

### 1.2 Set Environment Variables
Replace `<unique-name>` with a unique identifier (e.g., your initials + date).
```bash
RESOURCE_GROUP="nextauth-rg"
LOCATION="eastus"
ACR_NAME="nextauthacr<unique-name>"
CONTAINER_APP_NAME="nextauth-app"
IMAGE_NAME="nextauth-image"
```

---

## 🔹 Step 2: Create Azure Container Registry (ACR)

### 2.1 Create a Resource Group
```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### 2.2 Create Azure Container Registry (ACR)
```bash
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true
```

### 2.3 Log in to ACR
```bash
az acr login --name $ACR_NAME
```

---

## 🔹 Step 3: Push Docker Image to ACR

### 3.1 Get ACR Login Server
```bash
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query "loginServer" --output tsv)
```

### 3.2 Build & Tag the Docker Image for ACR
Make sure your Docker image is built before tagging.
```bash
docker build -t my-nextjs-app .
docker tag my-nextjs-app $ACR_LOGIN_SERVER/$IMAGE_NAME:v1
```

### 3.3 Push the Image to ACR
```bash
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:v1
```

---

## 🔹 Step 4: Deploy to Azure Container Apps (ACA)

### 4.1 Register ACA if Not Done Before
```bash
az provider register --namespace Microsoft.App
```

### 4.2 Enable ACA Extensions
```bash
az extension add --name containerapp --upgrade
```

### 4.3 Create an Azure Container App Environment
```bash
az containerapp env create --name nextauth-env --resource-group $RESOURCE_GROUP --location $LOCATION
```

### 4.4 Deploy the App to ACA
Replace the respective keys here and then run the command.
```bash
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment nextauth-env \
    --image $ACR_LOGIN_SERVER/$IMAGE_NAME:v1 \
    --registry-server $ACR_LOGIN_SERVER \
    --registry-username $(az acr credential show --name $ACR_NAME --query "username" --output tsv) \
    --registry-password $(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv) \
    --cpu 0.5 --memory 1Gi \
    --ingress external --target-port 3000 \
    --env-vars NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="your-pk" \
               CLERK_SECRET_KEY="your-sk" \
               NEXT_PUBLIC_CLERK_SIGN_IN_URL="/sign-in" \
               NEXT_PUBLIC_CLERK_SIGN_UP_URL="/sign-up" \
               NEXT_PUBLIC_CLERK_FRONTEND_API_URL="https://clerk.my-app.eastus.azurecontainerapps.io"
```

---

## 🔹 Step 5: Get Your App's URL
Retrieve the live URL of your deployed application.
```bash
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv
```
**Example Output:**
```
https://nextauth-app.somehash.region.azurecontainerapps.io
```

---

## 🔹 Step 6: Verify the Deployment
Open the URL in your browser.
- If you see your Next.js app running, the deployment is successful.
- If you get a **502 error**, wait a few minutes or check the logs.

---

## 🔹 Step 7: Check Logs (If Issues Occur)
If the deployment fails, use this command to check logs:
```bash
az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow
```

---
## **Current Status**
- The Next.js app has been **successfully deployed** on **Azure Container Apps**.
- The deployed application is accessible at:  
```
https://nextauth-app.somehash.region.azurecontainerapps.io
```
- Clerk authentication **requires a verified custom domain**, but currently, the app is running on Azure’s default domain (`*.azurecontainerapps.io`), which **cannot be configured with Clerk**.

## **Why Authentication Doesn't Work Yet**
- Clerk requires a **custom domain with DNS settings** to function correctly.
- The free `azurecontainerapps.io` domain **cannot be used** to verify Clerk's required DNS records.
- Without a custom domain, Clerk’s **Frontend API, Account Portal, and email verification won’t work**.

## **Next Steps (To Enable Authentication)**
1. **Purchase a custom domain** (e.g., `my-app.com`) or use an existing one.
2. **Set up DNS records** for Clerk authentication:
 - Add required **CNAME records** in the domain’s DNS settings.
 - Validate the domain in Clerk’s dashboard.
3. **Update the environment variables** in Azure:
 - Set `NEXT_PUBLIC_CLERK_FRONTEND_API_URL` to the **new custom domain**.
4. **Redeploy the application** with the updated domain settings.

## **Alternative Workaround (For Testing)**
If immediate testing is required before purchasing a custom domain:
- Use **Clerk’s development mode** for local testing.
- Ask the organization if they have a **subdomain** on an existing domain that can be used temporarily.

---

# **Final Note**

- Created **Azure Container Registry (ACR)**, built the image, and pushed it.
- Created an **Azure Container Apps (ACA) environment** and deployed the image from ACR.
- Configured environment variables inside the container.
- Retrieved the live URL and verified the deployment.

✅ **The application is fully deployed and functional except for authentication.**  
🚧 **Clerk authentication will work once a custom domain is configured.**  



Now your **Next.js app** is successfully deployed on **Azure Container Apps**! 🚀🎉

