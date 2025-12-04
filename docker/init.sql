CREATE TABLE document_tbl (
                              id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                              file_name VARCHAR(255) NOT NULL,
                              file_path VARCHAR(500) NOT NULL,
                              file_type VARCHAR(20) NOT NULL,
                              content TEXT,
                              tags VARCHAR(255),
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE document_tbl
    ADD COLUMN content_tsv tsvector;

CREATE FUNCTION document_tsv_trigger() RETURNS trigger AS $$
BEGIN
  NEW.content_tsv := to_tsvector('english', coalesce(NEW.content, ''));
RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate
    BEFORE INSERT OR UPDATE ON document_tbl
                         FOR EACH ROW
                         EXECUTE FUNCTION document_tsv_trigger();

CREATE INDEX idx_document_content_tsv
    ON document_tbl
    USING GIN(content_tsv);
