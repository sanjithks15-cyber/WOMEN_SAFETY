export const openapiSpec = {
  openapi: "3.0.0",
  info: {
    title: "SafeHer / SAMASOC Backend API",
    version: "1.0.0",
    description: "REST API for SafeHer / SAMASOC Women Safety App",
  },
  servers: [
    {
      url: "http://localhost:5000/api",
      description: "Local development server",
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
  security: [
    {
      BearerAuth: [],
    },
  ],
  paths: {
    "/auth/register": {
      post: {
        summary: "Register a new user",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  phone: { type: "string" },
                  name: { type: "string" },
                  pin: { type: "string" },
                  role: { type: "string", enum: ["USER", "ADMIN", "POLICE"] },
                },
                required: ["phone", "name", "pin"],
              },
            },
          },
        },
        responses: {
          201: { description: "User registered successfully" },
          400: { description: "Invalid input or phone already exists" },
        },
      },
    },
    "/auth/login": {
      post: {
        summary: "User login via phone & PIN",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  phone: { type: "string" },
                  pin: { type: "string" },
                },
                required: ["phone", "pin"],
              },
            },
          },
        },
        responses: {
          200: { description: "Login successful, returns token" },
          401: { description: "Invalid credentials" },
        },
      },
    },
    "/auth/profile": {
      get: {
        summary: "Get current user profile",
        responses: {
          200: { description: "User profile data" },
          401: { description: "Unauthorized" },
        },
      },
    },
    "/guardians": {
      post: {
        summary: "Add a trusted guardian",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  name: { type: "string" },
                  relation: { type: "string" },
                  phone: { type: "string" },
                },
                required: ["name", "relation", "phone"],
              },
            },
          },
        },
        responses: {
          201: { description: "Guardian contact added" },
        },
      },
      get: {
        summary: "Get user's guardians",
        responses: {
          200: { description: "List of guardians" },
        },
      },
    },
    "/sos/trigger": {
      post: {
        summary: "Trigger emergency SOS alert",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  latitude: { type: "number" },
                  longitude: { type: "number" },
                },
                required: ["latitude", "longitude"],
              },
            },
          },
        },
        responses: {
          201: { description: "Distress SOS alert generated" },
        },
      },
    },
    "/safety/crime-zones": {
      get: {
        summary: "Get crime zones with risk filtering & pagination",
        parameters: [
          { name: "riskLevel", in: "query", schema: { type: "string" } },
          { name: "page", in: "query", schema: { type: "integer" } },
          { name: "limit", in: "query", schema: { type: "integer" } },
        ],
        responses: {
          200: { description: "List of crime zones" },
        },
      },
    },
    "/safety/safe-places": {
      get: {
        summary: "Get nearby safe places with categories and pagination",
        parameters: [
          { name: "category", in: "query", schema: { type: "string" } },
          { name: "page", in: "query", schema: { type: "integer" } },
          { name: "limit", in: "query", schema: { type: "integer" } },
        ],
        responses: {
          200: { description: "List of safe places" },
        },
      },
    },
  },
};
