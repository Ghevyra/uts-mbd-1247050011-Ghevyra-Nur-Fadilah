CREATE SCHEMA IF NOT EXISTS salam;

CREATE TABLE salam.mahasiswas (
    id          SERIAL,
    nim         VARCHAR(10)  NOT NULL,
    nama        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    prodi       VARCHAR(50)  NOT NULL DEFAULT 'Informatika',
    angkatan    SMALLINT     NOT NULL,
    ipk         NUMERIC(3,2) NOT NULL DEFAULT 0,
    -- [PEMBEDA 1] kolom predikat terisi otomatis dari ipk
    predikat    VARCHAR(20)  GENERATED ALWAYS AS (
                    CASE WHEN ipk >= 3.50 THEN 'Cumlaude'
                         WHEN ipk >= 3.00 THEN 'Sangat Baik'
                         ELSE 'Baik' END
                ) STORED,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_mahasiswas        PRIMARY KEY (id),
    CONSTRAINT uq_mahasiswas_nim    UNIQUE (nim),
    CONSTRAINT uq_mahasiswas_email  UNIQUE (email),
    CONSTRAINT chk_mahasiswas_ipk   CHECK (ipk BETWEEN 0 AND 4),
    -- [PEMBEDA 2] constraint format NIM dan email
    CONSTRAINT chk_mahasiswas_nim   CHECK (nim ~ '^[0-9]{10}$'),
    CONSTRAINT chk_mahasiswas_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_mahasiswas_angk  CHECK (angkatan BETWEEN 2000 AND 2100)
);

-- [PEMBEDA 3] audit log otomatis (siapa mengubah data apa)
CREATE TABLE salam.mahasiswas_audit (
    audit_id  SERIAL PRIMARY KEY,
    aksi      VARCHAR(10) NOT NULL,
    nim       VARCHAR(10),

    db_user   TEXT        NOT NULL DEFAULT current_user,
    waktu     TIMESTAMP   NOT NULL DEFAULT NOW(),
    data      JSONB
);

CREATE OR REPLACE FUNCTION salam.fn_audit_mahasiswas() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO salam.mahasiswas_audit(aksi, nim, data) VALUES (TG_OP, OLD.nim, to_jsonb(OLD));
        RETURN OLD;
    ELSE
        INSERT INTO salam.mahasiswas_audit(aksi, nim, data) VALUES (TG_OP, NEW.nim, to_jsonb(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON salam.mahasiswas
FOR EACH ROW EXECUTE FUNCTION salam.fn_audit_mahasiswas();

-- [PEMBEDA 4] view mahasiswa cumlaude
CREATE VIEW salam.v_mahasiswa_cumlaude AS
SELECT nim, nama, ipk, predikat FROM salam.mahasiswas WHERE ipk >= 3.50;

-- Data awal
INSERT INTO salam.mahasiswas (nim, nama, email, angkatan, ipk) VALUES
('1247050011', 'Ghevyra Nur Fadilah', 'ghevyra@example.com', 2024, 3.80),
('1247050022', 'Budi Santoso',        'budi@example.com',    2024, 3.20),
('1247050033', 'Siti Aminah',         'siti@example.com',    2024, 3.60);