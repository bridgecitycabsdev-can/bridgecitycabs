# bridgecitycabs

Bridge City Cabs - Comprehensive fleet dispatch, administrative portal, backend API, and mobile applications (Passenger & Driver).

## Architecture

- **`apps/dispatch-web`**: Dispatch operations and administrative web portal built with React, Vite, Tailwind CSS, and TanStack.
- **`apps/api`**: Core backend API and real-time WebSocket dispatch engine built with NestJS, Prisma ORM, BullMQ, and Redis.
- **`apps/passenger-app`**: Native cross-platform passenger ride-hailing application built with Flutter.
- **`apps/driver-app`**: Native cross-platform driver dispatch, routing, and earnings application built with Flutter.
- **`packages/*`**: Shared design tokens, shared TypeScript interfaces, and API client libraries.

## Cloud Staging Infrastructure

- **Database**: PostgreSQL on [Neon.tech](https://neon.tech)
- **Cache & Real-time Feeds**: Redis on [Upstash.com](https://upstash.com)
- **Web Portal Hosting**: [Vercel](https://vercel.com) / [Netlify](https://netlify.com)
- **Backend API Hosting**: [Render](https://render.com) / [Koyeb](https://koyeb.com)
