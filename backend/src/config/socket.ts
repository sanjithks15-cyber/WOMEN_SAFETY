import { Server as SocketIOServer } from "socket.io";
import { Server as HttpServer } from "http";
import logger from "./logger";

export class SocketService {
  private static io: SocketIOServer | null = null;

  public static init(server: HttpServer): SocketIOServer {
    this.io = new SocketIOServer(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
    });

    this.io.on("connection", (socket) => {
      logger.info(`WebSocket client connected: ${socket.id}`);

      socket.on("join_user", (userId: string) => {
        socket.join(`user_${userId}`);
        logger.info(`Client ${socket.id} joined room user_${userId}`);
      });

      socket.on("join_journey", (journeyId: string) => {
        socket.join(`journey_${journeyId}`);
        logger.info(`Client ${socket.id} joined room journey_${journeyId}`);
      });

      socket.on("disconnect", () => {
        logger.info(`WebSocket client disconnected: ${socket.id}`);
      });
    });

    return this.io;
  }

  public static sendSOSAlert(userId: string, data: any) {
    if (!this.io) return;
    this.io.to(`user_${userId}`).emit("sos_alert", data);
    logger.info(`Real-time SOS alert broadcasted to user_${userId}`);
  }

  public static sendLocationUpdate(journeyId: string, data: { latitude: number; longitude: number; progress: number }) {
    if (!this.io) return;
    this.io.to(`journey_${journeyId}`).emit("location_changed", data);
    logger.info(`Real-time location updated for journey_${journeyId}`);
  }
}
