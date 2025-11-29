import { SetMetadata } from "@nestjs/common";
import { user_role } from "generated/prisma/enums.js";

/**
 * @Roles :
 */
export const ROLE_KEY = "roles";
export const Roles = (...roles : user_role[]) => SetMetadata(ROLE_KEY,roles)