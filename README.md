# Gatsby Starter Shopify App

[![CircleCI](https://circleci.com/gh/gil--/gatsby-starter-shopify-app.svg?style=svg)](https://circleci.com/gh/gil--/gatsby-starter-shopify-app)

### **[Try Demo](https://gatsby-starter-shopify-app.firebaseapp.com/install/)**

This Gatsby starter is a serverless Shopify app which runs using Firebase hosting and Firebase functions. It will allow for authenticated Shopify app access.

Note that Shopify Apps are meant to run within the Shopify Admin as a merchant facing experience. This is not a headless Shopify store experience.

> **Warning:** This app is not production ready. PRs are welcome as development continues towards a stable v1.0.0 release.

## Features
- 🗄Firebase Firestore Realtime DB
- ⚡️Serverless Functions API layer (Firebase Functions)
- 👩‍💼Admin API (Graphql) Serverless Proxy
- 🎨 Shopify Polaris (AppProvider, etc.)
- 💰 Application Charge  Logic (30 days) with variable trial duration
- 📡 Webhook Validation & Creation
- 🔑 GDPR Ready (Including GDPR Webhooks)
- 🏗 CircleCI Config for easy continuous deployments to Firebase

## Setup
1. Run `yarn` or `npm install` to install all depdencies
2. Install Firebase CLI globally `npm i -g firebase-cli`
3. Login to Firebase `firebase login`.
4. Create a new Firebase project from the [Firebase Console](https://console.firebase.google.com/).
5. Create a new file called `.env.development` in the root of this project and navigate to the `General Settings` page and copy the **Project ID** into .env. Set this to `FIREBASE_PROJECT_ID=`:

```bash
FIREBASE_PROJECT_ID=example-project-id
```

6. Register a new [Shopify App](https://partners.shopify.com) in your Partners portal.
7. Copy the API key and set it as *SHOPIFY_APP_API_KEY* in .env.development.
8. Go to `https://console.firebase.google.com/project/{FIREBASE-APP-NAME-HERE}/settings/serviceaccounts/adminsdk` or Project Settings > Service accounts. Now generate a new Firebase Admin SDK for Node.js and click the "Generate new private key". This will download a json file which we will use to authenticate to the Firebase Admin SDK from within our functions.

9. Run `firebase login` to login and authenticate.
10. Run `firebase init functions` and select the project you created in step 2.
12. In the Firebase console `https://console.firebase.google.com`, select your project and navigate to Database where you'll create a **Firestore Database**. Add a root collection called shops and add a base document with the following attributes:

| Name | Type | Value |
| :- | :- | :- |
| **Document Id** | | shopify.myshopify.com |
| |  |
| shop | string | shopify.myshopify.com |
| createdAt | timestamp | |
| updatedAt | timestamp | |

Note, because some of the Firebase functions such as /api/graphql and /callback make outside requests to Shopify API, you must use a non-free plan such as the "Pay-as-you-go" which includes the free plan tier. You will see an error in your Firebase functions logs saying *"Billing account not configured. External network is not accessible and quotas are severely limited. Configure billing account to remove these restriction."* 
11. run `source .env.development` to export your local env
12. run `./functions/config/runtime-config-setter.sh` 
to add required local variables to Firebase config
14. Start up the servers
run `npm start`
and `npm run ngrok`
and `firebase emulators:start`


## API Layer

This Shopify App runs on Firebase serverless infrastructure using Firebase functions as the API layer. There are three main API routes:

| API URL | Purpose |
| :- | :- |
| **/auth** | Begins initial process to create Shopify Admin authentication keys |
| **/callback** | Create authentication keys, setups up or updates store information in Firestore, and creates billing subscription |
| **/api/activate-charge** | Active App Subscription Charge |
| **/api/graphql** | Proxies all Shopify admin API requests. Requires account with billing enabled. Note that Firebase functions does not allow external API requests on free accounts. As a result, you must add billing information to your Firebase account to successfully proxy the Shopify admin API. |

> We currently don't use the common */api/**/* Firebase functions syntax with Express as I've found splitting the routes allows for easier debugging and clearer analytics. Cold starts have also gotten much better with Firebase functions which was one of the main drivers behind putting all API functions behind a common route.

## Webhooks

Webhook urls are prefix with `/webhook`.

| Webhook Topic | Route | Purpose |
| :- | :- | :- |
| **app/uninstalled** | `/webhook/uninstall` | This gets called by the uninstall webhook |
| **[GDPR Specific](https://help.shopify.com/en/api/guides/gdpr-resources) Webhooks** |  |  |
| **customers/redact** | `/webhook/customer-redact` | Requests deletion of customer data |
| **customers/data_request** | `/webhook/customers-data-request` | Requests to view stored customer data |
| **shop/redact** | `/webhook/shop-redact` | Requests deletion of shop data |

## Shopify Configurations

### Access Mode

Shopify has two types of [access modes](https://help.shopify.com/en/api/getting-started/authentication/oauth/api-access-modes), *online access* and *offline access*. You can read the official Shopify article for more information but it's important to note that this Shopify app is setup to use the online access token. This simply means that instead of a per-store access code, it's per store admin user. The main reasoning is that this app is serverless and as a result no server-side session logic resulting in the access token being store in the browser. Since the token can be easily revoked by the admin user and it expires in 24 hours, it's safer than using a long-lasting offline access token.

### API Scopes

Whenever a merchant installs a Shopify app, they are presented with a permission screen asking to accept an app's request to access certain data such as orders, customers, and products. The app knows which permissions to accept through the `scopes` setting. This is set as the Firebase configuration value of `shopify.app_scopes`. Shopify has a [full list](https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes) of API access scopes.

## Bugs/Issues
- Not *yet* production ready
- Missing Integration Tests
- Missing better bug tracking/integration (BugSnag, Google StackDriver or equivalent)
- Infrequent oauth issues such as Safari cookie redirect
