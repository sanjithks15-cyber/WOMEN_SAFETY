import { NextFunction, Response } from "express";
import jwt from "jsonwebtoken";
import { UnauthorizedException } from "../exceptions/http.exception";
import { AuthenticatedRequest } from "./authenticated-request.interface";

const JWT_SECRET = process.env.JWT_SECRET || "safeher_super_secret_key_12345!";

export const authMiddleware = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new UnauthorizedException("Access token is missing or invalid"));
  }

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as {
      id: string;
      phone: string;
      role: string;
    };
    req.user = decoded;
    next();
  } catch (error) {
    next(new UnauthorizedException("Invalid token"));
  }
};
