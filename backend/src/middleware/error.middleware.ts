import { NextFunction, Request, Response } from "express";
import { HttpException } from "../exceptions/http.exception";
import logger from "../config/logger";

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  let status = 500;
  let message = "Internal Server Error";

  if (error instanceof HttpException) {
    status = error.status;
    message = error.message;
  }

  logger.error(
    `[${req.method}] ${req.path} - Error: ${message} (Status: ${status})`,
    {
      stack: error.stack,
      url: req.originalUrl,
      body: req.body,
      params: req.params,
      query: req.query,
    }
  );

  res.status(status).json({
    status,
    message,
    timestamp: new Date().toISOString(),
  });
};
