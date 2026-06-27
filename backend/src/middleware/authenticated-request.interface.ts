import { Request } from "express";

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    phone: string;
    role: string;
  };
}
