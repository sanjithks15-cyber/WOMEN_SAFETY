import { NextFunction, Response } from "express";
import { ForbiddenException, UnauthorizedException } from "../exceptions/http.exception";
import { AuthenticatedRequest } from "./authenticated-request.interface";

export const requireRoles = (allowedRoles: string[]) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new UnauthorizedException("Authentication required"));
    }

    const hasRole = allowedRoles.includes(req.user.role);
    if (!hasRole) {
      return next(new ForbiddenException("You do not have permission to access this resource"));
    }

    next();
  };
};
