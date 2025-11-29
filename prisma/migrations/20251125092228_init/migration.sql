-- CreateEnum
CREATE TYPE "user_status" AS ENUM ('active', 'inactive', 'suspended', 'locked');

-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('superadmin', 'admin', 'moderator', 'user', 'guest');

-- CreateEnum
CREATE TYPE "mfa_method" AS ENUM ('totp', 'sms', 'email');

-- CreateEnum
CREATE TYPE "audit_action" AS ENUM ('LOGIN', 'LOGOUT', 'LOGIN_FAILED', 'PASSWORD_CHANGED', 'PASSWORD_RESET_REQUESTED', 'PASSWORD_RESET_COMPLETED', 'EMAIL_VERIFIED', 'MFA_ENABLED', 'MFA_DISABLED', 'MFA_VERIFIED', 'USER_CREATED', 'USER_UPDATED', 'USER_DELETED', 'USER_SUSPENDED', 'USER_ACTIVATED', 'SESSION_CREATED', 'SESSION_REVOKED', 'SESSION_EXPIRED', 'POST_CREATED', 'POST_UPDATED', 'POST_DELETED', 'POST_PUBLISHED', 'COMMENT_CREATED', 'COMMENT_UPDATED', 'COMMENT_DELETED', 'PERMISSION_GRANTED', 'PERMISSION_REVOKED', 'ROLE_CHANGED');

-- CreateEnum
CREATE TYPE "audit_status" AS ENUM ('success', 'failed', 'error', 'warning');

-- CreateEnum
CREATE TYPE "comment_status" AS ENUM ('approved', 'pending', 'spam', 'rejected');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('new_post', 'comment', 'reaction', 'mention', 'system', 'security_alert');

-- CreateEnum
CREATE TYPE "post_status" AS ENUM ('draft', 'pending', 'published', 'archived');

-- CreateEnum
CREATE TYPE "post_visibility" AS ENUM ('public', 'internal', 'department', 'private');

-- CreateEnum
CREATE TYPE "reaction_type" AS ENUM ('like', 'love', 'insightful', 'celebrate');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(50) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "full_name" VARCHAR(100) NOT NULL,
    "avatar_url" VARCHAR(255),
    "phone_number" VARCHAR(20),
    "department_id" INTEGER,
    "is_email_verified" BOOLEAN NOT NULL DEFAULT false,
    "email_verified_at" TIMESTAMP(6),
    "email_verification_token" VARCHAR(255),
    "password_changed_at" TIMESTAMP(6),
    "password_expires_at" TIMESTAMP(6),
    "must_change_password" BOOLEAN NOT NULL DEFAULT false,
    "failed_login_attempts" INTEGER NOT NULL DEFAULT 0,
    "locked_until" TIMESTAMP(6),
    "last_login_at" TIMESTAMP(6),
    "last_login_ip" VARCHAR(45),
    "last_login_user_agent" VARCHAR(500),
    "status" "user_status" NOT NULL DEFAULT 'active',
    "role" "user_role" NOT NULL DEFAULT 'user',
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,
    "deleted_at" TIMESTAMP(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" TEXT NOT NULL,
    "user_id" INTEGER NOT NULL,
    "refresh_token" VARCHAR(500) NOT NULL,
    "access_token_jti" VARCHAR(100),
    "ip_address" VARCHAR(45),
    "user_agent" VARCHAR(500),
    "device_info" JSONB,
    "location" VARCHAR(100),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "expires_at" TIMESTAMP(6) NOT NULL,
    "last_activity" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revoked_at" TIMESTAMP(6),
    "revoked_reason" VARCHAR(255),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mfa_secrets" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "secret" VARCHAR(255) NOT NULL,
    "backup_codes" JSONB,
    "method" "mfa_method" NOT NULL DEFAULT 'totp',
    "is_enabled" BOOLEAN NOT NULL DEFAULT false,
    "verified_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "mfa_secrets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL NOT NULL,
    "user_id" INTEGER,
    "action" "audit_action" NOT NULL,
    "resource_type" VARCHAR(50),
    "resource_id" VARCHAR(100),
    "ip_address" VARCHAR(45),
    "user_agent" VARCHAR(500),
    "correlation_id" VARCHAR(100) NOT NULL,
    "status" "audit_status" NOT NULL DEFAULT 'success',
    "error_message" TEXT,
    "error_code" VARCHAR(50),
    "metadata" JSONB,
    "duration_ms" INTEGER,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "password_resets" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "token" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMP(6) NOT NULL,
    "used_at" TIMESTAMP(6),
    "ip_address" VARCHAR(45),
    "user_agent" VARCHAR(500),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_resets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "login_attempts" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "email" VARCHAR(100) NOT NULL,
    "ip_address" VARCHAR(45) NOT NULL,
    "user_agent" VARCHAR(500),
    "success" BOOLEAN NOT NULL,
    "error_message" VARCHAR(255),
    "error_code" VARCHAR(50),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "login_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "resource" VARCHAR(50) NOT NULL,
    "action" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "role" "user_role" NOT NULL,
    "permission_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role","permission_id")
);

-- CreateTable
CREATE TABLE "user_permissions" (
    "user_id" INTEGER NOT NULL,
    "permission_id" INTEGER NOT NULL,
    "granted" BOOLEAN NOT NULL DEFAULT true,
    "granted_by" INTEGER,
    "granted_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(6),

    CONSTRAINT "user_permissions_pkey" PRIMARY KEY ("user_id","permission_id")
);

-- CreateTable
CREATE TABLE "user_settings" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "language" VARCHAR(10) NOT NULL DEFAULT 'vi',
    "timezone" VARCHAR(50) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    "date_format" VARCHAR(20) NOT NULL DEFAULT 'DD/MM/YYYY',
    "email_notifications" BOOLEAN NOT NULL DEFAULT true,
    "push_notifications" BOOLEAN NOT NULL DEFAULT true,
    "notification_frequency" VARCHAR(20) NOT NULL DEFAULT 'realtime',
    "two_factor_enabled" BOOLEAN NOT NULL DEFAULT false,
    "session_timeout_minutes" INTEGER NOT NULL DEFAULT 480,
    "require_password_change_days" INTEGER DEFAULT 90,
    "theme" VARCHAR(20) NOT NULL DEFAULT 'light',
    "sidebar_collapsed" BOOLEAN NOT NULL DEFAULT false,
    "items_per_page" INTEGER NOT NULL DEFAULT 20,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "user_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attachments" (
    "id" SERIAL NOT NULL,
    "post_id" INTEGER NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "file_path" VARCHAR(500) NOT NULL,
    "file_type" VARCHAR(50),
    "file_size" BIGINT,
    "uploaded_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bookmarks" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "post_id" INTEGER NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bookmarks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categories" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "parent_id" INTEGER,
    "display_order" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6),

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "comments" (
    "id" SERIAL NOT NULL,
    "post_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "parent_id" INTEGER,
    "content" TEXT NOT NULL,
    "status" "comment_status" DEFAULT 'approved',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6),

    CONSTRAINT "comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6),

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "type" "notification_type" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "content" TEXT,
    "related_post_id" INTEGER,
    "related_user_id" INTEGER,
    "is_read" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_department_access" (
    "post_id" INTEGER NOT NULL,
    "department_id" INTEGER NOT NULL,

    CONSTRAINT "post_department_access_pkey" PRIMARY KEY ("post_id","department_id")
);

-- CreateTable
CREATE TABLE "post_revisions" (
    "id" SERIAL NOT NULL,
    "post_id" INTEGER NOT NULL,
    "title" VARCHAR(255),
    "content" TEXT,
    "edited_by" INTEGER NOT NULL,
    "edit_note" VARCHAR(255),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_revisions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_tags" (
    "post_id" INTEGER NOT NULL,
    "tag_id" INTEGER NOT NULL,

    CONSTRAINT "post_tags_pkey" PRIMARY KEY ("post_id","tag_id")
);

-- CreateTable
CREATE TABLE "posts" (
    "id" SERIAL NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(255) NOT NULL,
    "content" TEXT NOT NULL,
    "excerpt" TEXT,
    "featured_image" VARCHAR(255),
    "author_id" INTEGER NOT NULL,
    "category_id" INTEGER,
    "status" "post_status" DEFAULT 'draft',
    "visibility" "post_visibility" DEFAULT 'internal',
    "view_count" INTEGER DEFAULT 0,
    "is_pinned" BOOLEAN DEFAULT false,
    "published_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6),

    CONSTRAINT "posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reactions" (
    "id" SERIAL NOT NULL,
    "post_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "reaction_type" "reaction_type" NOT NULL,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tags" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "slug" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tags_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_username_idx" ON "users"("username");

-- CreateIndex
CREATE INDEX "users_department_id_idx" ON "users"("department_id");

-- CreateIndex
CREATE INDEX "users_status_role_idx" ON "users"("status", "role");

-- CreateIndex
CREATE INDEX "users_is_email_verified_idx" ON "users"("is_email_verified");

-- CreateIndex
CREATE INDEX "users_last_login_at_idx" ON "users"("last_login_at");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_refresh_token_key" ON "sessions"("refresh_token");

-- CreateIndex
CREATE INDEX "sessions_user_id_is_active_idx" ON "sessions"("user_id", "is_active");

-- CreateIndex
CREATE INDEX "sessions_refresh_token_idx" ON "sessions"("refresh_token");

-- CreateIndex
CREATE INDEX "sessions_expires_at_idx" ON "sessions"("expires_at");

-- CreateIndex
CREATE INDEX "sessions_last_activity_idx" ON "sessions"("last_activity");

-- CreateIndex
CREATE UNIQUE INDEX "mfa_secrets_user_id_key" ON "mfa_secrets"("user_id");

-- CreateIndex
CREATE INDEX "audit_logs_user_id_created_at_idx" ON "audit_logs"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_correlation_id_idx" ON "audit_logs"("correlation_id");

-- CreateIndex
CREATE INDEX "audit_logs_action_created_at_idx" ON "audit_logs"("action", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_resource_type_resource_id_idx" ON "audit_logs"("resource_type", "resource_id");

-- CreateIndex
CREATE INDEX "audit_logs_status_created_at_idx" ON "audit_logs"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "password_resets_token_key" ON "password_resets"("token");

-- CreateIndex
CREATE INDEX "password_resets_token_expires_at_idx" ON "password_resets"("token", "expires_at");

-- CreateIndex
CREATE INDEX "password_resets_user_id_created_at_idx" ON "password_resets"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "login_attempts_email_created_at_idx" ON "login_attempts"("email", "created_at");

-- CreateIndex
CREATE INDEX "login_attempts_ip_address_created_at_idx" ON "login_attempts"("ip_address", "created_at");

-- CreateIndex
CREATE INDEX "login_attempts_user_id_success_created_at_idx" ON "login_attempts"("user_id", "success", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_name_key" ON "permissions"("name");

-- CreateIndex
CREATE INDEX "user_permissions_expires_at_idx" ON "user_permissions"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_settings_user_id_key" ON "user_settings"("user_id");

-- CreateIndex
CREATE INDEX "attachments_post_id_idx" ON "attachments"("post_id");

-- CreateIndex
CREATE INDEX "attachments_uploaded_by_idx" ON "attachments"("uploaded_by");

-- CreateIndex
CREATE INDEX "bookmarks_user_id_idx" ON "bookmarks"("user_id");

-- CreateIndex
CREATE INDEX "bookmarks_post_id_idx" ON "bookmarks"("post_id");

-- CreateIndex
CREATE UNIQUE INDEX "bookmarks_user_id_post_id_key" ON "bookmarks"("user_id", "post_id");

-- CreateIndex
CREATE UNIQUE INDEX "categories_slug_key" ON "categories"("slug");

-- CreateIndex
CREATE INDEX "categories_slug_idx" ON "categories"("slug");

-- CreateIndex
CREATE INDEX "categories_parent_id_idx" ON "categories"("parent_id");

-- CreateIndex
CREATE INDEX "idx_comments_post" ON "comments"("post_id");

-- CreateIndex
CREATE INDEX "idx_comments_user" ON "comments"("user_id");

-- CreateIndex
CREATE INDEX "comments_status_idx" ON "comments"("status");

-- CreateIndex
CREATE INDEX "departments_name_idx" ON "departments"("name");

-- CreateIndex
CREATE INDEX "idx_notifications_user_unread" ON "notifications"("user_id", "is_read");

-- CreateIndex
CREATE INDEX "notifications_created_at_idx" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "post_department_access_department_id_idx" ON "post_department_access"("department_id");

-- CreateIndex
CREATE INDEX "idx_post_revisions_post" ON "post_revisions"("post_id");

-- CreateIndex
CREATE INDEX "post_tags_tag_id_idx" ON "post_tags"("tag_id");

-- CreateIndex
CREATE UNIQUE INDEX "posts_slug_key" ON "posts"("slug");

-- CreateIndex
CREATE INDEX "idx_posts_author" ON "posts"("author_id");

-- CreateIndex
CREATE INDEX "idx_posts_published_at" ON "posts"("published_at");

-- CreateIndex
CREATE INDEX "idx_posts_status" ON "posts"("status");

-- CreateIndex
CREATE INDEX "posts_slug_idx" ON "posts"("slug");

-- CreateIndex
CREATE INDEX "posts_visibility_idx" ON "posts"("visibility");

-- CreateIndex
CREATE INDEX "reactions_post_id_idx" ON "reactions"("post_id");

-- CreateIndex
CREATE INDEX "reactions_user_id_idx" ON "reactions"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "reactions_post_id_user_id_reaction_type_key" ON "reactions"("post_id", "user_id", "reaction_type");

-- CreateIndex
CREATE UNIQUE INDEX "tags_name_key" ON "tags"("name");

-- CreateIndex
CREATE UNIQUE INDEX "tags_slug_key" ON "tags"("slug");

-- CreateIndex
CREATE INDEX "tags_slug_idx" ON "tags"("slug");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mfa_secrets" ADD CONSTRAINT "mfa_secrets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "password_resets" ADD CONSTRAINT "password_resets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "login_attempts" ADD CONSTRAINT "login_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permissions" ADD CONSTRAINT "user_permissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permissions" ADD CONSTRAINT "user_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_settings" ADD CONSTRAINT "user_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "categories"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "comments"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_related_post_id_fkey" FOREIGN KEY ("related_post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_related_user_id_fkey" FOREIGN KEY ("related_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_department_access" ADD CONSTRAINT "post_department_access_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_department_access" ADD CONSTRAINT "post_department_access_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_revisions" ADD CONSTRAINT "post_revisions_edited_by_fkey" FOREIGN KEY ("edited_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_revisions" ADD CONSTRAINT "post_revisions_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_tags" ADD CONSTRAINT "post_tags_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "post_tags" ADD CONSTRAINT "post_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "reactions" ADD CONSTRAINT "reactions_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "reactions" ADD CONSTRAINT "reactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
