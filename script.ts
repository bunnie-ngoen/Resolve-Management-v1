import { prisma } from './src/lib/prisma.js';
	import * as bcrypt from 'bcrypt';
	
	async function main() {
	  console.log('🌱 Seeding database...');
	
	  const hashedPassword = await bcrypt.hash('Admin@123', 12);
	
	  // SUPER ADMIN
	  const superAdmin = await prisma.users.upsert({
	    where: { email: 'superadmin@example.com' },
	    update: {},
	    create: {
	      username: 'superadmin',
	      email: 'superadmin@example.com',
	      password_hash: hashedPassword,
	      full_name: 'Super Admin',
	      role: 'superadmin',     // ENUM user_role
	      status: 'active',        // ENUM user_status
	      is_email_verified: true,
	    },
	  });
	
	  console.log('✅ Super Admin:', superAdmin.email);
	
	  // ADMIN
	  const admin = await prisma.users.upsert({
	    where: { email: 'admin@example.com' },
	    update: {},
	    create: {
	      username: 'admin',
	      email: 'admin@example.com',
	      password_hash: hashedPassword,
	      full_name: 'Admin User',
	      role: 'admin',
	      status: 'active',
	      is_email_verified: true,
	    },
	  });
	
	  console.log('✅ Admin:', admin.email);
	
	  // REGULAR USER
	  const user = await prisma.users.upsert({
	    where: { email: 'user@example.com' },
	    update: {},
	    create: {
	      username: 'user01',
	      email: 'user@example.com',
	      password_hash: hashedPassword,
	      full_name: 'Regular User',
	      role: 'user',
	      status: 'active',
	      is_email_verified: true,
	    },
	  });
	
	  console.log('✅ User:', user.email);
	
	  console.log('\n🎉 Seeding completed!\n');
	  console.log('📝 Accounts');
	  console.log('superadmin@example.com | Admin@123');
	  console.log('admin@example.com      | Admin@123');
	  console.log('user@example.com       | Admin@123');
	}
	
	main()
	  .catch((e) => {
	    console.error('❌ Seeding failed:', e);
	    process.exit(1);
	  })
	  .finally(async () => {
	    await prisma.$disconnect();
	  });

