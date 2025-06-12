/*
  # Policy Management Database Schema

  1. New Tables
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `created_at` (timestamp)
    - `policies`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `category_id` (uuid, foreign key to categories)
      - `status` (boolean, default true)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    - `policy_attachments`
      - `id` (uuid, primary key)
      - `policy_id` (uuid, foreign key to policies)
      - `file_url` (text)
      - `file_name` (text)
      - `created_at` (timestamp)
    - `policy_versions`
      - `id` (uuid, primary key)
      - `policy_id` (uuid, foreign key to policies)
      - `version_number` (integer)
      - `changes` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their data

  3. Relationships
    - Policies belong to categories
    - Policy attachments belong to policies
    - Policy versions belong to policies
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create policies table
CREATE TABLE IF NOT EXISTS policies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  status boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create policy_attachments table
CREATE TABLE IF NOT EXISTS policy_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id uuid REFERENCES policies(id) ON DELETE CASCADE,
  file_url text NOT NULL,
  file_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create policy_versions table
CREATE TABLE IF NOT EXISTS policy_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_id uuid REFERENCES policies(id) ON DELETE CASCADE,
  version_number integer NOT NULL,
  changes text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_versions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for categories
CREATE POLICY "Users can read all categories"
  ON categories
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert categories"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update categories"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can delete categories"
  ON categories
  FOR DELETE
  TO authenticated
  USING (true);

-- Create RLS policies for policies
CREATE POLICY "Users can read all policies"
  ON policies
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert policies"
  ON policies
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update policies"
  ON policies
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can delete policies"
  ON policies
  FOR DELETE
  TO authenticated
  USING (true);

-- Create RLS policies for policy_attachments
CREATE POLICY "Users can read all policy attachments"
  ON policy_attachments
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert policy attachments"
  ON policy_attachments
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update policy attachments"
  ON policy_attachments
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can delete policy attachments"
  ON policy_attachments
  FOR DELETE
  TO authenticated
  USING (true);

-- Create RLS policies for policy_versions
CREATE POLICY "Users can read all policy versions"
  ON policy_versions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert policy versions"
  ON policy_versions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update policy versions"
  ON policy_versions
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can delete policy versions"
  ON policy_versions
  FOR DELETE
  TO authenticated
  USING (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_policies_category_id ON policies(category_id);
CREATE INDEX IF NOT EXISTS idx_policies_status ON policies(status);
CREATE INDEX IF NOT EXISTS idx_policies_created_at ON policies(created_at);
CREATE INDEX IF NOT EXISTS idx_policy_attachments_policy_id ON policy_attachments(policy_id);
CREATE INDEX IF NOT EXISTS idx_policy_versions_policy_id ON policy_versions(policy_id);
CREATE INDEX IF NOT EXISTS idx_policy_versions_version_number ON policy_versions(policy_id, version_number);

-- Insert some default categories
INSERT INTO categories (name, description) VALUES
  ('Recursos Humanos', 'Políticas relacionadas a gestão de pessoas e recursos humanos'),
  ('Tecnologia da Informação', 'Políticas de segurança, uso de sistemas e tecnologia'),
  ('Financeiro', 'Políticas financeiras, orçamentárias e de controle'),
  ('Operacional', 'Políticas operacionais e de processos internos'),
  ('Compliance', 'Políticas de conformidade e regulamentações')
ON CONFLICT (name) DO NOTHING;