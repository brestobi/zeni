# Plan: Admin Dashboard Implementation

## Objective
Create a secure, web-based Admin Dashboard for the Zeni platform to enable management of riders, drivers, vehicles, and ride data.

## Tech Stack Recommendation
*   **Framework:** React (using Vite) or Next.js (for built-in routing and SSR).
*   **UI Library:** Shadcn UI + Tailwind CSS (efficient, modern, and highly customizable).
*   **State Management:** TanStack Query (perfect for fetching and caching Supabase data).
*   **Backend Interface:** Supabase JS Client (reusing the same project instance).

## Key Features
1.  **Dashboard/Analytics:** Overview of daily/weekly/monthly active users and completed rides.
2.  **User Management:**
    *   List/search/filter passengers and drivers.
    *   View user details and account status.
    *   Toggle driver status (suspend/activate).
3.  **Driver Approval Workflow:**
    *   List pending driver registrations.
    *   Review submitted vehicle and license documents.
    *   Approve/Reject driver accounts.
4.  **Ride Monitoring:**
    *   List all rides (live and past).
    *   Basic filtering by date, status, and users.

## Implementation Steps
1.  **Project Setup:** Initialize a new `admin_dashboard/` folder at the root.
2.  **Authentication:** Configure Supabase Auth for admin access (using a dedicated `admins` table or Role-based access via custom claims if available).
3.  **Dashboard UI:** Setup routing and basic navigation layout.
4.  **Feature Implementation:** Build individual modules (User, Ride, Approval managers).
5.  **Security:** Ensure RLS policies in Supabase prevent unauthorized access from the dashboard.

## Verification
*   Verify successful login via Admin Supabase account.
*   Confirm data reflects current database state.
*   Ensure RLS policies are applied for admin-only functions.
