import http from "http";
import app from "./app";
import logger from "./config/logger";
import { SocketService } from "./config/socket";

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);
SocketService.init(server);

server.listen(PORT, () => {
  logger.info(`Server successfully started on port ${PORT}`);
  logger.info(`API Docs available at http://localhost:${PORT}/api-docs`);
});
