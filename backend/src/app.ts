import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import swaggerUi from "swagger-ui-express";
import router from "./routes/api.routes";
import { errorHandler } from "./middleware/error.middleware";
import { requestLogger } from "./middleware/request-logger.middleware";
import { openapiSpec } from "./docs/openapi";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.use(requestLogger);

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(openapiSpec));

app.use("/api", router);

app.use(errorHandler);

export default app;
