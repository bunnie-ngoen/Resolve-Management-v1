import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { user_role } from "generated/prisma/enums.js";
import { Observable } from "rxjs";
import { ROLE_KEY } from "../decorators/roles.decorator.js";

@Injectable()
export class RolesGuard implements CanActivate {
    //reflector : dùng để đọc metadata(roles) đã gắn bằng decorator @Roles()
    constructor(private reflector: Reflector) { }
    canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
      const requiredRoles = this.reflector.getAllAndOverride<user_role[]>(ROLE_KEY,[
        context.getHandler(),
        context.getClass(),
      ])
      //nếu route không yêu cầu role thì pass
      if(!requiredRoles){
        return true
      }
      //lấy user từ request
      const {user} = context.switchToHttp().getRequest();
      const hasRole = requiredRoles.some((role) =>user.role ===role);
      if(!hasRole){
        throw new ForbiddenException('Insufficient permissions')
      }
      return true;
    }
}