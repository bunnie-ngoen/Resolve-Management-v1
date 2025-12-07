import { user_role } from "generated/prisma/enums.js";
import { User } from "src/modules/user/entities/user.entity.js";

export interface JwtPayload{
    sub :number,
    email : string ,
    username : string,
    role : user_role,
    jti? : string,
}

export interface TokenResponse{
    accessToken : string,  
    refreshToken :string,
    expiresIn : number,
}
export interface LoginResponse extends TokenResponse{
    user: Omit<User, 'password_hash'>;  // Loại bỏ password_hash
}
export interface AuthenticatedUser{
    id : number,
    email : string,
    username : string,
    role : user_role
}

