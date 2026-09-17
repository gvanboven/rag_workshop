# Infra for the RAG workshop (learning setup)

Bicep files to provision the cheapest possible Azure resources covering the
prerequisites in the main [README](../README.md), for learning purposes only
(not sized or configured for production).

## What this deploys

- **Resource group** — new, created by this deployment.
- **Azure OpenAI** (`Microsoft.CognitiveServices`, kind `OpenAI`), S0, Sweden
  Central, with two model deployments:
  - `gpt-5-mini` — used for both chat and reranking (`AZURE_OPENAI_DEPLOYMENT_NAME`
    and `AZURE_OPENAI_RERANK_DEPLOYMENT_NAME` point to the same deployment).
  - `text-embedding-3-small` — used for embeddings (replaces the sample's
    legacy `ada` deployment name).
- **Azure AI Search**, Free (F1) tier — no cost.
  **Limitation:** F1 does not support the Semantic ranker add-on used by the
  "Search, Augmentation and Answer generation" notebook's hybrid search
  step. You'll need to upgrade to Basic tier or higher (~$75/month) if you
  want to exercise that specific feature.
- **Azure Document Intelligence**, Free (F0) tier — no cost.
  **Limitation:** capped at 500 pages/month, with per-document page limits
  depending on the model used. Fine for the sample PDFs in `docs/`, not for
  production volumes.
- **Storage Account**, Standard_LRS, blob only — used for `BLOB_CONNECTION_STRING`.

**Out of scope** (not provisioned by this Bicep):
- SQLite + Flask endpoint — runs locally, see the "Run the local SQLite endpoint"
  section below.
- PostgreSQL — bring your own if/when you reach that part of the workshop.

## Prerequisites

- An Azure subscription.
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- Bicep CLI: `az bicep install`.
- (Option A only) [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) installed.

## Deploy

### Option A: `azd up` (recommended, one command)

This repo has an `azure.yaml` at the root pointing azd at `infra/main.bicep`
(subscription-scope deployment — azd supports this natively, no resource
group needs to exist beforehand).

```bash
azd auth login
azd up
```

`azd up` will prompt you to pick/create an azd environment name and an Azure
subscription/location the first time you run it — the environment name is
just a local label for your `azd env` state, it does **not** affect Azure
resource names (those come from the fixed `ragws` prefix in
[`main.parameters.json`](main.parameters.json)).

To tear down everything azd created:

```bash
azd down
```

### Option B: raw `az deployment` commands

1. Log in and select your subscription:

   ```bash
   az login
   az account set --subscription "<your-subscription-id-or-name>"
   ```

2. Preview what will be created (recommended — costs nothing, changes nothing):

   ```bash
   az deployment sub what-if \
     --location swedencentral \
     --template-file infra/main.bicep
   ```

3. Deploy:

   ```bash
   az deployment sub create \
     --name rag-workshop-infra \
     --location swedencentral \
     --template-file infra/main.bicep
   ```

   Optional parameters (defaults shown):

   ```bash
   az deployment sub create \
     --name rag-workshop-infra \
     --location swedencentral \
     --template-file infra/main.bicep \
     --parameters resourceGroupName=rg-rag-workshop location=swedencentral namePrefix=ragws
   ```

## Fill in your `.env`

The deployment does not output API keys directly (avoids keys landing in
deployment history/logs). Fetch them yourself after deploying:

```bash
RG=rg-rag-workshop   # or your resourceGroupName parameter value

# Azure OpenAI endpoint + key
az cognitiveservices account show \
  --name <your-openai-account-name> --resource-group $RG \
  --query "properties.endpoint" -o tsv
az cognitiveservices account keys list \
  --name <your-openai-account-name> --resource-group $RG \
  --query "key1" -o tsv

# Azure AI Search endpoint + query key
az search service show \
  --name <your-search-service-name> --resource-group $RG \
  --query "hostName" -o tsv
az search query-key list \
  --service-name <your-search-service-name> --resource-group $RG \
  --query "[0].key" -o tsv

# Document Intelligence endpoint + key
az cognitiveservices account show \
  --name <your-docintel-account-name> --resource-group $RG \
  --query "properties.endpoint" -o tsv
az cognitiveservices account keys list \
  --name <your-docintel-account-name> --resource-group $RG \
  --query "key1" -o tsv

# Storage connection string
az storage account show-connection-string \
  --name <your-storage-account-name> --resource-group $RG \
  --query "connectionString" -o tsv
```

Resource names are generated with a `uniqueString()` suffix; get the exact
names from the deployment outputs or `az resource list --resource-group $RG -o table`.

Map the values into your `.env` (see [`.env-sample`](../.env-sample) at the repo root):

```
AZURE_OPENAI_ENDPOINT=<openai endpoint>
AZURE_OPENAI_API_KEY=<openai key1>
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-5-mini
AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME=text-embedding-3-small
AZURE_OPENAI_RERANK_DEPLOYMENT_NAME=gpt-5-mini
AZURE_OPENAI_API_VERSION=2024-12-01-preview

SEARCH_SERVICE_ENDPOINT=https://<search-service-name>.search.windows.net
SEARCH_SERVICE_QUERY_KEY=<search query key>

DOC_INTEL_ENDPOINT=<docintel endpoint>
DOC_INTEL_KEY=<docintel key1>

BLOB_CONNECTION_STRING=<storage connection string>
```

## Run the local SQLite endpoint

The `.env-sample`'s `SQLITE_ENDPOINT=http://127.0.0.1:5000/sqlite-query` is a
locally-run Flask app, not an Azure resource. See
[`1_indexing/app.py`](../1_indexing/app.py) — run it with:

```bash
python 1_indexing/app.py
```

`SQLITE_USER` / `SQLITE_PASSWORD` in `.env-sample` are the credentials this
local endpoint expects.

## Tear down

If you used `azd up`, run `azd down` instead (cleans up azd's own state too).
Otherwise, delete the resource group directly:

```bash
az group delete --name rg-rag-workshop --yes --no-wait
```
