# Paystack Integration API Documentation

## Overview
This document provides comprehensive information about all Paystack-related API endpoints for mobile app frontend integration with the Kena backend.

## API Base Path
```
/api/subscription
```

## Authentication
Most endpoints require authentication via Bearer token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## API Endpoints

### 1. Get Client Configuration

**Endpoint:** `GET /api/subscription/config`  
**Authentication:** Not required  
**Purpose:** Initialize Paystack SDK with public key and configuration

#### Response
```json
{
  "status": 200,
  "message": "Paystack config",
  "data": [
    {
      "provider": "paystack",
      "publicKey": "pk_test_...",
      "publishableKey": "pk_test_...",
      "trialDays": 19,
      "callbackUrl": "https://your-domain.com/api/subscription/webhook"
    }
  ]
}
```

#### Response Fields
- `provider` (string): Payment provider identifier ("paystack")
- `publicKey` (string): Paystack public key for client-side SDK initialization
- `publishableKey` (string): Alias for publicKey (for compatibility)
- `trialDays` (number): Number of trial days configured (default: 19)
- `callbackUrl` (string): Webhook URL for Paystack callbacks

---

### 2. Get Available Plans

**Endpoint:** `GET /api/subscription/plans`  
**Authentication:** Not required  
**Purpose:** Fetch all available subscription plans for the pricing screen

#### Response
```json
{
  "status": 200,
  "message": "Plans",
  "data": [
    {
      "plans": [
        {
          "priceId": "PLN_monthly_code",
          "productId": "12345",
          "name": "Monthly Plan",
          "currency": "ngn",
          "unitAmount": 50000,
          "unitAmountDecimal": "500.00",
          "interval": "month",
          "intervalCount": 1,
          "planName": "Monthly Plan"
        },
        {
          "priceId": "PLN_annual_code",
          "productId": "12346",
          "name": "Annual Plan",
          "currency": "ngn",
          "unitAmount": 500000,
          "unitAmountDecimal": "5000.00",
          "interval": "year",
          "intervalCount": 1,
          "planName": "Annual Plan"
        }
      ],
      "trialDays": 19
    }
  ]
}
```

#### Response Fields
- `plans` (array): List of available subscription plans
  - `priceId` (string): Paystack plan code for subscription creation
  - `productId` (string): Paystack product ID
  - `name` (string): Plan display name
  - `currency` (string): ISO currency code (e.g., "ngn")
  - `unitAmount` (number): Price in smallest currency unit (kobo for NGN)
  - `unitAmountDecimal` (string): Price in decimal format (e.g., "500.00")
  - `interval` (string): Billing interval ("month", "year", "week")
  - `intervalCount` (number): Number of intervals per billing cycle
  - `planName` (string): Display name for the plan
- `trialDays` (number): Trial period duration in days

---

### 3. Get Current Subscription

**Endpoint:** `GET /api/subscription/me`  
**Authentication:** Required  
**Purpose:** Check user's current subscription status on app launch/profile screen

#### Headers
```
Authorization: Bearer <token>
```

#### Query Parameters
- `previewPriceId` (optional, string): Preview subscription details for a specific plan

#### Response (No Subscription)
```json
{
  "status": 200,
  "message": "Subscription",
  "data": [
    {
      "hasSubscription": false,
      "provider": "paystack",
      "status": "none",
      "priceId": null,
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": null,
      "trialEnd": null,
      "willRenew": false,
      "isActive": false,
      "isTrial": false,
      "subscriptionType": null,
      "daysRemaining": null,
      "subscriptionCode": null,
      "customerCode": null,
      "pendingReference": null,
      "pendingPlanCode": null,
      "price": null
    }
  ]
}
```

#### Response (Active Subscription)
```json
{
  "status": 200,
  "message": "Subscription",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "active",
      "rawStatus": "active",
      "priceId": "PLN_monthly_code",
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": "2026-05-15T00:00:00.000Z",
      "trialEnd": null,
      "willRenew": true,
      "isActive": true,
      "isTrial": false,
      "subscriptionType": "monthly",
      "daysRemaining": 25,
      "subscriptionCode": "SUB_abc123",
      "customerCode": "CUS_xyz789",
      "pendingReference": null,
      "pendingPlanCode": null,
      "price": {
        "priceId": "PLN_monthly_code",
        "currency": "ngn",
        "unitAmount": 50000,
        "unitAmountDecimal": "500.00",
        "interval": "month"
      }
    }
  ]
}
```

#### Response (Trial)
```json
{
  "status": 200,
  "message": "Subscription",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "trial_setup",
      "rawStatus": "trial_setup",
      "priceId": null,
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": null,
      "trialEnd": null,
      "willRenew": false,
      "isActive": false,
      "isTrial": true,
      "subscriptionType": null,
      "daysRemaining": 19,
      "subscriptionCode": null,
      "customerCode": null,
      "pendingReference": null,
      "pendingPlanCode": null,
      "price": null
    }
  ]
}
```

#### Response Fields
- `hasSubscription` (boolean): Whether user has any subscription
- `provider` (string): Payment provider ("paystack")
- `status` (string): Subscription status ("none", "active", "trial_setup", "trialing", "past_due", "canceled", "pending")
- `rawStatus` (string): Original status from Paystack
- `priceId` (string|null): Current plan's Paystack plan code
- `cancelAtPeriodEnd` (boolean): Whether subscription will cancel at period end
- `currentPeriodEnd` (string|null): ISO date string of current billing period end
- `trialEnd` (string|null): ISO date string of trial period end
- `willRenew` (boolean): Whether subscription will auto-renew
- `isActive` (boolean): Whether subscription is currently active (including trial)
- `isTrial` (boolean): Whether user is currently in trial period
- `subscriptionType` (string|null): "monthly" or "annual" (null for trial users)
- `daysRemaining` (number|null): Days remaining in trial or billing period
- `subscriptionCode` (string|null): Paystack subscription code
- `customerCode` (string|null): Paystack customer code
- `pendingReference` (string|null): Pending transaction reference
- `pendingPlanCode` (string|null): Pending plan code for plan changes
- `price` (object|null): Current plan details

---

### 4. Create Mobile Subscription

**Endpoint:** `POST /api/subscription/mobile/subscribe`  
**Authentication:** Required  
**Purpose:** Create subscription with Paystack checkout (supports trial flow)

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{
  "priceId": "PLN_monthly_code",
  "forceCheckout": false
}
```

#### Request Fields
- `priceId` (string, required): Paystack plan code for the chosen plan
- `forceCheckout` (boolean, optional): Skip trial and force direct payment (default: false)

#### Response (Trial Mode)
```json
{
  "status": 200,
  "message": "Trial setup initialized",
  "data": [
    {
      "mode": "trial_setup",
      "provider": "paystack",
      "trialDays": 19,
      "subscription": {
        "hasSubscription": true,
        "provider": "paystack",
        "status": "trial_setup",
        "isTrial": true,
        "daysRemaining": 19,
        "subscriptionType": null
      }
    }
  ]
}
```

#### Response (Direct Payment)
```json
{
  "status": 200,
  "message": "Subscription initialized",
  "data": [
    {
      "provider": "paystack",
      "authorizationUrl": "https://checkout.paystack.co/...",
      "accessCode": "ACCESS_CODE",
      "reference": "kena-sub-userId-1234567890",
      "subscription": {
        "hasSubscription": true,
        "provider": "paystack",
        "status": "pending",
        "rawStatus": "pending",
        "priceId": "PLN_monthly_code",
        "subscriptionType": "monthly",
        "pendingReference": "kena-sub-userId-1234567890",
        "pendingPlanCode": "PLN_monthly_code",
        "daysRemaining": null
      }
    }
  ]
}
```

#### Response Fields (Trial Mode)
- `mode` (string): "trial_setup" indicating trial initialization
- `provider` (string): Payment provider
- `trialDays` (number): Trial period duration
- `subscription` (object): Trial subscription state

#### Response Fields (Direct Payment)
- `provider` (string): Payment provider
- `authorizationUrl` (string): Paystack checkout URL to redirect user to
- `accessCode` (string): Paystack access code for inline checkout
- `reference` (string): Transaction reference for tracking
- `subscription` (object): Pending subscription state

#### Error Responses
- `400`: Missing or invalid `priceId`
- `400`: User email is required for Paystack checkout
- `401`: Unauthorized
- `409`: Subscription already exists (returns current subscription state)

---

### 5. Create Mobile Setup Intent (Trial Flow)

**Endpoint:** `POST /api/subscription/mobile/setup-intent`  
**Authentication:** Required  
**Purpose:** Initialize trial by setting up trial subscription

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{}
```

#### Response
```json
{
  "status": 200,
  "message": "Trial setup initialized",
  "data": [
    {
      "provider": "paystack",
      "mode": "trial_setup",
      "trialDays": 19,
      "subscription": {
        "hasSubscription": true,
        "provider": "paystack",
        "status": "trial_setup",
        "isTrial": true,
        "daysRemaining": 19,
        "subscriptionType": null
      }
    }
  ]
}
```

#### Error Responses
- `401`: Unauthorized
- `409`: Trial already used (user has already had a trial)
- `409`: Subscription already exists

---

### 6. Activate Mobile Subscription

**Endpoint:** `POST /api/subscription/mobile/activate`  
**Authentication:** Required  
**Purpose:** Activate subscription after successful Paystack payment

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{
  "reference": "kena-sub-userId-1234567890",
  "priceId": "PLN_monthly_code"
}
```

#### Request Fields
- `reference` (string, required): Paystack transaction reference from checkout
- `priceId` (string, optional): Plan code (can be inferred from transaction)
- `setupIntentId` (string, optional): Alias for reference (for compatibility)

#### Response
```json
{
  "status": 200,
  "message": "Subscription activated",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "active",
      "rawStatus": "active",
      "priceId": "PLN_monthly_code",
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": "2026-06-15T00:00:00.000Z",
      "trialEnd": null,
      "willRenew": true,
      "isActive": true,
      "isTrial": false,
      "subscriptionType": "monthly",
      "daysRemaining": 30,
      "subscriptionCode": "SUB_abc123",
      "customerCode": "CUS_xyz789",
      "pendingReference": null,
      "pendingPlanCode": null,
      "price": {
        "priceId": "PLN_monthly_code",
        "currency": "ngn",
        "unitAmount": 50000,
        "unitAmountDecimal": "500.00",
        "interval": "month"
      }
    }
  ]
}
```

#### Error Responses
- `400`: Missing or invalid `reference`
- `400`: Transaction not successful
- `401`: Unauthorized

---

### 7. Cancel Subscription

**Endpoint:** `POST /api/subscription/cancel`  
**Authentication:** Required  
**Purpose:** Cancel subscription (stops auto-renewal at period end)

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{}
```

#### Response (Trial Cancellation)
```json
{
  "status": 200,
  "message": "Trial canceled",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "canceled",
      "rawStatus": "canceled",
      "priceId": null,
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": null,
      "trialEnd": "2026-05-04T00:00:00.000Z",
      "willRenew": false,
      "isActive": false,
      "isTrial": false,
      "subscriptionType": null,
      "daysRemaining": 0
    }
  ]
}
```

#### Response (Active Subscription Cancellation)
```json
{
  "status": 200,
  "message": "Subscription set to stop renewing",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "active",
      "rawStatus": "non-renewing",
      "priceId": "PLN_monthly_code",
      "cancelAtPeriodEnd": true,
      "currentPeriodEnd": "2026-05-15T00:00:00.000Z",
      "trialEnd": null,
      "willRenew": false,
      "isActive": true,
      "isTrial": false,
      "subscriptionType": "monthly",
      "daysRemaining": 25
    }
  ]
}
```

#### Error Responses
- `401`: Unauthorized
- `404`: Subscription not found

---

### 8. Renew Subscription

**Endpoint:** `POST /api/subscription/renew`  
**Authentication:** Required  
**Purpose:** Reactivate a canceled subscription (removes cancel_at_period_end flag)

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{}
```

#### Response
```json
{
  "status": 200,
  "message": "Subscription renewed",
  "data": [
    {
      "hasSubscription": true,
      "provider": "paystack",
      "status": "active",
      "rawStatus": "active",
      "priceId": "PLN_monthly_code",
      "cancelAtPeriodEnd": false,
      "currentPeriodEnd": "2026-06-15T00:00:00.000Z",
      "trialEnd": null,
      "willRenew": true,
      "isActive": true,
      "isTrial": false,
      "subscriptionType": "monthly",
      "daysRemaining": 30,
      "subscriptionCode": "SUB_abc123",
      "customerCode": "CUS_xyz789"
    }
  ]
}
```

#### Error Responses
- `400`: Trial users cannot renew (must start paid checkout)
- `401`: Unauthorized
- `404`: Subscription not found

---

### 9. Change Plan

**Endpoint:** `POST /api/subscription/change`  
**Authentication:** Required  
**Purpose:** Upgrade/downgrade subscription plan

#### Headers
```
Authorization: Bearer <token>
```

#### Request Body
```json
{
  "newPriceId": "PLN_annual_code"
}
```

#### Request Fields
- `newPriceId` (string, required): Paystack plan code for the new plan

#### Response
```json
{
  "status": 200,
  "message": "Plan change initialized",
  "data": [
    {
      "provider": "paystack",
      "authorizationUrl": "https://checkout.paystack.co/...",
      "accessCode": "ACCESS_CODE",
      "reference": "kena-change-userId-1234567890",
      "subscription": {
        "hasSubscription": true,
        "provider": "paystack",
        "status": "active",
        "priceId": "PLN_monthly_code",
        "subscriptionType": "monthly",
        "pendingPlanCode": "PLN_annual_code",
        "pendingReference": "kena-change-userId-1234567890",
        "daysRemaining": 25
      },
      "nextPlan": {
        "priceId": "PLN_annual_code",
        "currency": "ngn",
        "unitAmount": 500000,
        "unitAmountDecimal": "5000.00",
        "interval": "year",
        "planName": "Annual Plan"
      }
    }
  ]
}
```

#### Response Fields
- `provider` (string): Payment provider
- `authorizationUrl` (string): Paystack checkout URL for plan change payment
- `accessCode` (string): Paystack access code for inline checkout
- `reference` (string): Transaction reference for tracking
- `subscription` (object): Current subscription state with pending changes
- `nextPlan` (object): New plan details

#### Error Responses
- `400`: Missing or invalid `newPriceId`
- `400`: User email is required for Paystack checkout
- `401`: Unauthorized
- `404`: Subscription not found
- `400`: Plan is already active

---

### 10. Paystack Webhook

**Endpoint:** `POST /api/subscription/webhook`  
**Authentication:** Not required (webhook endpoint)  
**Purpose:** Receive and process Paystack webhook events

#### Headers
```
Content-Type: application/json
x-paystack-signature: <signature>
```

#### Request Body
Paystack sends a JSON payload with event data:
```json
{
  "event": "charge.success",
  "data": {
    "reference": "kena-sub-userId-1234567890",
    "amount": 50000,
    "currency": "NGN",
    "customer": {
      "customer_code": "CUS_xyz789",
      "email": "user@example.com"
    },
    "subscription": {
      "subscription_code": "SUB_abc123",
      "plan": {
        "plan_code": "PLN_monthly_code"
      }
    },
    "metadata": {
      "userId": "user_id",
      "planCode": "PLN_monthly_code"
    }
  }
}
```

#### Supported Event Types
- `charge.success`: Successful payment transaction
- `subscription.create`: New subscription created
- `subscription.not_renew`: Subscription set to not renew
- `subscription.disable`: Subscription disabled/canceled
- `invoice.update`: Subscription invoice updated (renewal)
- `invoice.payment_failed`: Payment failed

#### Response
```json
{
  "received": true
}
```

#### Webhook Setup Instructions

1. **Configure Paystack Webhook**
   - Go to Paystack Dashboard > Settings > Webhooks
   - Add your webhook URL: `https://your-domain.com/api/subscription/webhook`
   - Copy the webhook secret for signature verification

2. **Environment Variables**
   Ensure these are set in your `.env` file:
   ```env
   PAYSTACK_SECRET_KEY=sk_test_...
   PAYSTACK_PUBLIC_KEY=pk_test_...
   PAYSTACK_CALLBACK_URL=https://your-domain.com/api/subscription/webhook
   PAYSTACK_PLAN_CODES=PLN_monthly_code,PLN_annual_code
   PAYSTACK_TRIAL_DAYS=19
   ```

---

### 11. Get Recent Activities

**Endpoint:** `GET /api/subscription/activities`  
**Authentication:** Required  
**Purpose:** Fetch subscription-related activity history

#### Headers
```
Authorization: Bearer <token>
```

#### Query Parameters
- `limit` (optional, number): Number of activities to return (default: 50)

#### Example Request
```
GET /api/subscription/activities?limit=20
```

#### Response
```json
{
  "status": 200,
  "message": "Recent activities",
  "data": [
    {
      "userId": "...",
      "action": "trial_started",
      "details": { "trialDays": 19 },
      "timestamp": "2026-04-15T10:30:00.000Z"
    },
    {
      "userId": "...",
      "action": "subscribed",
      "details": { "subscriptionType": "monthly" },
      "timestamp": "2026-04-15T11:00:00.000Z"
    },
    {
      "userId": "...",
      "action": "payment_succeeded",
      "details": { "amount": 50000, "currency": "NGN" },
      "timestamp": "2026-04-15T11:05:00.000Z"
    }
  ]
}
```

#### Response Fields
- `userId` (string): User ID who performed the action
- `action` (string): Activity type (trial_started, subscribed, payment_succeeded, payment_failed, subscription_cancelled, subscription_renewed, plan_changed, trial_expired)
- `details` (object): Additional details about the action (varies by action type)
- `timestamp` (string): ISO date string of when the action occurred

---

### 12. Get Subscription History

**Endpoint:** `GET /api/subscription/history`  
**Authentication:** Required  
**Purpose:** Fetch detailed subscription history with spending information

#### Headers
```
Authorization: Bearer <token>
```

#### Query Parameters
- `limit` (optional, number): Number of history records to return (default: 50)

#### Response
```json
{
  "status": 200,
  "message": "Subscription history",
  "data": [
    {
      "history": [
        {
          "userId": "...",
          "changeType": "trial_started",
          "previousStatus": null,
          "newStatus": "trial_setup",
          "metadata": { "source": "mobile_subscription", "trialDays": 19 },
          "createdAt": "2026-04-15T10:30:00.000Z"
        },
        {
          "userId": "...",
          "changeType": "subscribed",
          "previousStatus": "trial_setup",
          "newStatus": "active",
          "previousSubscriptionType": null,
          "newSubscriptionType": "monthly",
          "priceAmount": 50000,
          "priceAmountDecimal": 500.00,
          "currency": "ngn",
          "planName": "Monthly Plan",
          "createdAt": "2026-04-15T11:00:00.000Z"
        }
      ],
      "totalSpent": "500.00",
      "totalSpentCents": 50000,
      "totalPurchases": 1,
      "purchases": [
        {
          "date": "2026-04-15T11:00:00.000Z",
          "planName": "Monthly Plan",
          "amount": 500.00,
          "currency": "ngn",
          "changeType": "subscribed",
          "priceId": "PLN_monthly_code",
          "subscriptionType": "monthly"
        }
      ],
      "currency": "ngn"
    }
  ]
}
```

#### Response Fields
- `history` (array): Detailed subscription change history
  - `changeType` (string): Type of change (trial_started, subscribed, subscription_cancelled, subscription_renewed, plan_changed, payment_succeeded, payment_failed)
  - `previousStatus` (string|null): Previous subscription status
  - `newStatus` (string): New subscription status
  - `previousSubscriptionType` (string|null): Previous subscription type
  - `newSubscriptionType` (string|null): New subscription type
  - `priceAmount` (number|null): Price in smallest currency unit
  - `priceAmountDecimal` (number|null): Price in decimal format
  - `currency` (string|null): Currency code
  - `planName` (string|null): Plan name
  - `metadata` (object): Additional metadata
  - `createdAt` (string): ISO date string
- `totalSpent` (string): Total amount spent in decimal format
- `totalSpentCents` (number): Total amount spent in smallest currency unit
- `totalPurchases` (number): Total number of purchases
- `purchases` (array): List of individual purchases
- `currency` (string): Currency code

---

## Mobile App Flow Sequences

### New User Trial Flow (Recommended)

1. **Initialize Paystack SDK**
   - Call: `GET /api/subscription/config`
   - Use: `publicKey` to initialize Paystack SDK

2. **Display Pricing**
   - Call: `GET /api/subscription/plans`
   - Display: Available plans with pricing and trial information

3. **Check Subscription Status**
   - Call: `GET /api/subscription/me`
   - Verify: User doesn't already have an active subscription

4. **Start Trial Setup**
   - Call: `POST /api/subscription/mobile/setup-intent`
   - Result: Trial subscription initialized with `status: "trial_setup"`

5. **Complete Trial Activation**
   - User can now use the app during trial period
   - Trial days are calculated from `trialStartedAt`

6. **Convert to Paid Subscription**
   - Call: `POST /api/subscription/mobile/subscribe` with `forceCheckout: true`
   - Or call: `POST /api/subscription/mobile/subscribe` with `priceId` after trial ends
   - User completes Paystack checkout via `authorizationUrl`

7. **Activate Subscription**
   - Call: `POST /api/subscription/mobile/activate` with `reference` from checkout
   - Result: Active subscription created

---

### Direct Subscription Flow (No Trial)

1. **Initialize Paystack SDK**
   - Call: `GET /api/subscription/config`

2. **Display Pricing**
   - Call: `GET /api/subscription/plans`

3. **Create Subscription**
   - Call: `POST /api/subscription/mobile/subscribe`
   - Send: `priceId` (chosen plan) and `forceCheckout: true`

4. **Complete Payment**
   - Redirect user to `authorizationUrl` or use `accessCode` for inline checkout
   - User completes payment via Paystack

5. **Activate Subscription**
   - Call: `POST /api/subscription/mobile/activate` with `reference`
   - Result: Active subscription created

6. **Verify Subscription**
   - Call: `GET /api/subscription/me`
   - Confirm: `status: "active"` and `isActive: true`

---

### Existing User Check (App Launch)

1. **Check Subscription Status**
   - Call: `GET /api/subscription/me`
   - Display: Appropriate UI based on subscription state
   - Show: Trial days remaining if in trial, renewal date if active

---

### Plan Change Flow (Upgrade/Downgrade)

1. **Check Current Subscription**
   - Call: `GET /api/subscription/me`
   - Verify: User has active subscription

2. **Display Available Plans**
   - Call: `GET /api/subscription/plans`
   - Highlight: Current plan and available alternatives

3. **Change Plan**
   - Call: `POST /api/subscription/change`
   - Send: `newPriceId`

4. **Complete Payment**
   - Redirect user to `authorizationUrl` from response
   - User completes payment for new plan via Paystack

5. **Activate New Plan**
   - Webhook automatically processes the plan change
   - Or call: `POST /api/subscription/mobile/activate` with new `reference`

6. **Verify Change**
   - Call: `GET /api/subscription/me`
   - Confirm: New `priceId` and `subscriptionType`

---

### Cancellation Flow

1. **Show Current Subscription**
   - Call: `GET /api/subscription/me`
   - Display: Current plan, billing date, and cancellation options

2. **User Confirms Cancellation**
   - Present options: Cancel at period end (recommended)

3. **Cancel Subscription**
   - Call: `POST /api/subscription/cancel`
   - Result: Subscription set to not renew (`cancelAtPeriodEnd: true`)

4. **Verify Cancellation**
   - Call: `GET /api/subscription/me`
   - Confirm: `cancelAtPeriodEnd: true` and `willRenew: false`

---

### Renewal Flow (Reactivate Canceled Subscription)

1. **Check Subscription Status**
   - Call: `GET /api/subscription/me`
   - Verify: Subscription is active but set to not renew

2. **Reactivate Subscription**
   - Call: `POST /api/subscription/renew`
   - No request body required

3. **Verify Renewal**
   - Call: `GET /api/subscription/me`
   - Confirm: `cancelAtPeriodEnd: false` and `willRenew: true`

---

## Subscription Status Values

| Status | Description | isActive | isTrial |
|--------|-------------|----------|---------|
| `none` | No subscription | false | false |
| `trial_setup` | Trial payment setup in progress | false | true |
| `trialing` | Active trial period | true | true |
| `pending` | Subscription pending payment/activation | false | false |
| `active` | Active paid subscription | true | false |
| `past_due` | Payment failed, subscription past due | false | false |
| `canceled` | Subscription canceled | false | false |
| `unknown` | Unknown status | false | false |

---

## Error Response Format

All endpoints return errors in the following format:

```json
{
  "status": <error_code>,
  "message": "<error_message>",
  "data": null
}
```

### Common HTTP Status Codes
- `200`: Success
- `400`: Bad Request (invalid parameters)
- `401`: Unauthorized (invalid or missing token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found (subscription doesn't exist)
- `409`: Conflict (subscription already exists, trial already used)
- `500`: Internal Server Error

---

## Environment Variables

Required environment variables for Paystack integration:

```env
# Paystack Configuration
PAYSTACK_SECRET_KEY=sk_test_...  # Paystack secret key
PAYSTACK_PUBLIC_KEY=pk_test_...  # Paystack public key
PAYSTACK_CALLBACK_URL=https://your-domain.com/api/subscription/webhook

# Plan Configuration
PAYSTACK_PLAN_CODES=PLN_monthly_code,PLN_annual_code
PAYSTACK_PLAN_MONTHLY_CODE=PLN_monthly_code
PAYSTACK_PLAN_ANNUAL_CODE=PLN_annual_code

# Trial Configuration
PAYSTACK_TRIAL_DAYS=19

# Currency (optional, defaults to NGN)
PAYSTACK_CURRENCY=NGN
```

---

## Notes

### Trial Period
- Default trial period is 19 days (configurable via `PAYSTACK_TRIAL_DAYS`)
- Trial users have `subscriptionType: null` and `status: "trial_setup"`
- Trial can only be used once per user
- After trial expires, users need to convert to paid subscription

### Subscription Types
- `monthly`: Monthly billing
- `annual`: Annual billing
- `null`: Trial user

### Paystack Checkout Integration
- Use `authorizationUrl` to redirect users to Paystack's hosted checkout page
- Use `accessCode` for inline checkout integration with Paystack Inline JS
- Always verify transactions using the `reference` before activating subscriptions

### Webhook Security
- Webhook signature is verified using `x-paystack-signature` header
- Ensure your webhook URL is publicly accessible
- Paystack retries failed webhook deliveries

### Currency
- Default currency is NGN (Nigerian Naira)
- Amounts are in smallest currency unit (kobo for NGN)
- `unitAmountDecimal` provides the decimal representation for display

---

## Paystack SDK Integration

### Frontend Setup

1. **Install Paystack Inline**
   ```bash
   npm install paystack-js
   # or
   yarn add paystack-js
   ```

2. **Initialize Paystack**
   ```javascript
   import Paystack from 'paystack-js';
   
   const paystack = Paystack({
     publicKey: 'pk_test_...' // from GET /api/subscription/config
   });
   ```

3. **Inline Checkout Example**
   ```javascript
   const handler = PaystackPop.setup({
     key: 'pk_test_...',
     email: 'user@example.com',
     amount: 50000, // in kobo
     currency: 'NGN',
     reference: 'kena-sub-userId-1234567890',
     callback: function(response) {
       // Call POST /api/subscription/mobile/activate with response.reference
       activateSubscription(response.reference);
     },
     onClose: function() {
       // Handle modal close
     }
   });
   
   handler.openIframe();
   ```

4. **Redirect Checkout Example**
   ```javascript
   // Redirect user to authorizationUrl from API response
   window.location.href = data.authorizationUrl;
   ```

---

## Support

For questions or issues related to Paystack integration APIs, contact the backend development team.

## Paystack Resources

- [Paystack Documentation](https://paystack.com/docs/)
- [Paystack API Reference](https://paystack.com/docs/api/)
- [Paystack Inline JS](https://paystack.com/docs/paystack-inline/)
- [Paystack Webhooks](https://paystack.com/docs/webhooks/)
