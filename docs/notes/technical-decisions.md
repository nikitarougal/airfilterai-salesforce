# Technical Decisions

## 1. Service Layer Pattern

Business logic is placed in Apex service classes:

- `FilterMatchingService`
- `PricingCalculationService`
- `InquiryProcessingService`

This keeps the LWC controller lightweight and makes the logic reusable from Flow, REST APIs, and future integrations.

## 2. Flow for Automation

A record-triggered Flow processes new Customer Inquiry records automatically.

This allows Salesforce admins to understand and manage the automation flow while still relying on Apex for complex matching and pricing logic.

## 3. Invocable Apex

`InquiryProcessingFlowAction` exposes the Apex service layer to Flow.

This creates a bridge between declarative automation and custom code.

## 4. Exact Match First

The MVP uses exact matching on width, height, depth, and MERV rating.

Future versions can support nearest-size recommendations, tolerance matching, or custom quote logic.

## 5. Pricing Rules as Data

Pricing rules are stored in the `Pricing_Rule__c` object.

This avoids hardcoding discount logic directly in Apex and makes the solution easier to extend.