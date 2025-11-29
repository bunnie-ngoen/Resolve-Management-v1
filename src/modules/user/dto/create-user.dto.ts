import { IsEmail, IsNotEmpty, MinLength, Matches, IsOptional, IsString } from "class-validator";
export class CreateUserDto {
    @IsString()
    @IsNotEmpty()
    @MinLength(4)
    // decorator dùng để kiểm tra xem giá trị của property có khớp với một regex không
    @Matches(/^[a-zA-Z0-9_]+$/, {
        message: 'Username can only contain letters, numbers and underscore',
    })
    username: string;
    
    @IsEmail()
    @IsNotEmpty()
    email : string;

    @IsString()
    @IsNotEmpty()
    passsword : string;

    @IsString()
    @IsNotEmpty()
    full_name : string

    @IsString()
    @IsNotEmpty()
    phone_number : string

    @IsOptional()
    department_id? : number; //cách viết của optional

}
