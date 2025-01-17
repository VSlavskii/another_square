# Another Square
Flutter package for Square REST Apis. 

This package has been forked from https://github.com/CodeMinion/another_square
Dependencies are updated and tested with Flutter 3.19.0
Minor fixes are made around token refresh code.

## Square APIs

| Feature | Supported   | URL  |
|---|:---:|---|
| Payments  | Y  | https://developer.squareup.com/reference/square/payments-api  |
| Terminal  | Y  |https://developer.squareup.com/reference/square/terminal-api  |
| Order  | Y  | https://developer.squareup.com/reference/square/orders-api  |
| Subscription  | Y  | https://developer.squareup.com/reference/square/subscriptions-api  |
| Invoice  | Y  | https://developer.squareup.com/reference/square/invoices-api  |
| Catalog  | Y  | https://developer.squareup.com/reference/square/catalog-api  |
| Inventory  | Y  | https://developer.squareup.com/reference/square/inventory-api  |
| Customer  | Y  | https://developer.squareup.com/reference/square/customers-api  |
| Loyalty  | Y  | https://developer.squareup.com/reference/square/loyalty-api  |
| Gift Cards  | Y  | https://developer.squareup.com/reference/square/gift-cards-api  |
| Bookings  | Y  | https://developer.squareup.com/reference/square/bookings-api  |
| Business  | Y  | https://developer.squareup.com/reference/square/merchants-api  |
| Team  | Y  | https://developer.squareup.com/reference/square/team-api  |
| Financial  | Y  | https://developer.squareup.com/reference/square/bank-accounts-api  |
| Online  | Y  | https://developer.squareup.com/reference/square/sites-api  |
| Token  | Y  | https://developer.squareup.com/reference/square/oauth-api  |

## Credentials

In order to interact with Square you'll need a developer account and the clientId and clientSecret https://developer.squareup.com/apps

```dart
final squareClient = SquareClient(
    applicationId: applicationId,
    clientId: clientId,
    clientSecret: clientSecret,
    environmentType: EnvironmentType.Sandbox);
// Initialize the client.        
await squareClient.initialize();

// Use this to prompt the user to authorize your app
var authUrl = squareClient.getAuthorizationPageUrl(
        scopes: [Scope.CustomerWrite,Scope.CustomerRead,],         
        redirectUrl: <your redirect url>, 
        state: "state123")

// On authorization success use the params to get the access token.
var autoToken = squareClient.getAuthToken(
        code: <code from redirect url>,
        redirectUrl: <redirect url>);
        
// Note: The token can be refreshed when it expires using the refreshToken
String token = (await squareClient.refreshToken(
        refreshToken: autoToken.refresh_token
    )).accessToken
```