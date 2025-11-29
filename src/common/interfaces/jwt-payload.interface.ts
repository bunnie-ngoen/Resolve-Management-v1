import { user_role } from "generated/prisma/enums.js";

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
export interface AuthenticatedUser{
    id : number,
    email : string,
    username : string,
    role : user_role
}