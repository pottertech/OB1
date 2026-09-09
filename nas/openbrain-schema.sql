--
-- PostgreSQL database dump
--

\restrict CbGH01KGrnwyKUZj3PKTcsqDPfvcfjqpaClbBhnWqpemN1Ni433yYJUMczXB78P

-- Dumped from database version 17.9 (Debian 17.9-1.pgdg12+1)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: openbrain; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA openbrain;



--
-- Name: set_updated_at(); Type: FUNCTION; Schema: openbrain; Owner: emily_rw
--

CREATE FUNCTION openbrain.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.updated_at = now();
    return new;
end;
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_events; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.audit_events (
    xid text NOT NULL,
    event_type text NOT NULL,
    action text NOT NULL,
    result text NOT NULL,
    record_xid text,
    source_agent_xid text,
    source_instance_xid text,
    session_xid text,
    correlation_xid text,
    causation_xid text,
    summary text,
    payload_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT audit_events_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: TABLE audit_events; Type: COMMENT; Schema: openbrain; Owner: emily_rw
--

COMMENT ON TABLE openbrain.audit_events IS 'Traceability for reads, writes, and context generation';


--
-- Name: context_pack_items; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.context_pack_items (
    xid text NOT NULL,
    context_pack_xid text NOT NULL,
    item_type text NOT NULL,
    item_xid text NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    reason text,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT context_pack_items_rank_check CHECK ((rank >= 0)),
    CONSTRAINT context_pack_items_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: context_packs; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.context_packs (
    xid text NOT NULL,
    pack_type text NOT NULL,
    title text,
    source_agent_xid text,
    source_instance_xid text,
    session_xid text,
    correlation_xid text,
    content_text text,
    structured_content_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT context_packs_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: TABLE context_packs; Type: COMMENT; Schema: openbrain; Owner: emily_rw
--

COMMENT ON TABLE openbrain.context_packs IS 'Generated context bundles for agent consumption';


--
-- Name: embeddings; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.embeddings (
    xid text NOT NULL,
    owner_type text NOT NULL,
    owner_xid text NOT NULL,
    embedding_model text DEFAULT 'bge-m3'::text NOT NULL,
    embedding_dimensions integer DEFAULT 1024 NOT NULL,
    embedding_vector public.vector(1024),
    embedding_hash text,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT embeddings_dimensions_valid CHECK ((embedding_dimensions > 0)),
    CONSTRAINT embeddings_owner_type_check CHECK ((owner_type ~~ 'memory_record%'::text)),
    CONSTRAINT embeddings_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: TABLE embeddings; Type: COMMENT; Schema: openbrain; Owner: emily_rw
--

COMMENT ON TABLE openbrain.embeddings IS 'Vector embeddings for open-brain native memory_records ONLY. A-RAG documents use A-RAG embeddings.';


--
-- Name: jack_lead_queue; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.jack_lead_queue (
    id integer NOT NULL,
    workflow_id character varying(50),
    lead_data jsonb NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    error_message text,
    created_at timestamp without time zone DEFAULT now(),
    processed_at timestamp without time zone,
    retry_count integer DEFAULT 0,
    notification_sent boolean DEFAULT false
);



--
-- Name: jack_lead_queue_id_seq; Type: SEQUENCE; Schema: openbrain; Owner: emily_rw
--

CREATE SEQUENCE openbrain.jack_lead_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: jack_lead_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: openbrain; Owner: emily_rw
--

ALTER SEQUENCE openbrain.jack_lead_queue_id_seq OWNED BY openbrain.jack_lead_queue.id;


--
-- Name: memory_records; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.memory_records (
    xid text NOT NULL,
    memory_type text NOT NULL,
    authority_tier integer DEFAULT 3 NOT NULL,
    review_status text DEFAULT 'unreviewed'::text NOT NULL,
    retention_class text DEFAULT 'durable'::text NOT NULL,
    source_agent_xid text NOT NULL,
    source_instance_xid text NOT NULL,
    session_xid text,
    correlation_xid text,
    parent_xid text,
    causation_xid text,
    supersedes_xid text,
    superseded_by_xid text,
    arag_document_xid text,
    arag_chunk_xid text,
    lc_conversation_xid text,
    content_text text,
    content_summary text,
    structured_content_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    fingerprint text,
    captured_at timestamp with time zone,
    effective_at timestamp with time zone,
    expires_at timestamp with time zone,
    status text DEFAULT 'active'::text NOT NULL,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT memory_records_authority_tier_check CHECK (((authority_tier >= 0) AND (authority_tier <= 9))),
    CONSTRAINT memory_records_content_present CHECK (((content_text IS NOT NULL) OR (content_summary IS NOT NULL) OR (structured_content_json <> '{}'::jsonb))),
    CONSTRAINT memory_records_not_self_parent CHECK (((parent_xid IS NULL) OR (parent_xid <> xid))),
    CONSTRAINT memory_records_not_self_superseded_by CHECK (((superseded_by_xid IS NULL) OR (superseded_by_xid <> xid))),
    CONSTRAINT memory_records_not_self_supersedes CHECK (((supersedes_xid IS NULL) OR (supersedes_xid <> xid))),
    CONSTRAINT memory_records_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: TABLE memory_records; Type: COMMENT; Schema: openbrain; Owner: emily_rw
--

COMMENT ON TABLE openbrain.memory_records IS 'Operational memory submitted by agents using client-generated XIDs';


--
-- Name: memory_records_with_embeddings; Type: VIEW; Schema: openbrain; Owner: emily_rw
--

CREATE VIEW openbrain.memory_records_with_embeddings AS
 SELECT mr.xid,
    mr.memory_type,
    mr.content_text,
    mr.content_summary,
    mr.authority_tier,
    e.embedding_vector,
    e.embedding_model,
    e.embedding_dimensions
   FROM (openbrain.memory_records mr
     LEFT JOIN openbrain.embeddings e ON (((e.owner_xid = mr.xid) AND (e.owner_type = 'memory_record'::text))))
  WHERE (mr.status = 'active'::text);



--
-- Name: source_agents; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.source_agents (
    xid text NOT NULL,
    agent_key text NOT NULL,
    display_name text NOT NULL,
    agent_type text NOT NULL,
    trust_tier integer DEFAULT 3 NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    capabilities_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT source_agents_trust_tier_check CHECK (((trust_tier >= 0) AND (trust_tier <= 9))),
    CONSTRAINT source_agents_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: source_instances; Type: TABLE; Schema: openbrain; Owner: emily_rw
--

CREATE TABLE openbrain.source_instances (
    xid text NOT NULL,
    agent_xid text NOT NULL,
    instance_key text NOT NULL,
    host_name text,
    environment text DEFAULT 'prod'::text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    last_seen_at timestamp with time zone,
    metadata_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT source_instances_xid_check CHECK ((xid ~ '^[a-z0-9]{20}$'::text))
);



--
-- Name: jack_lead_queue id; Type: DEFAULT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.jack_lead_queue ALTER COLUMN id SET DEFAULT nextval('openbrain.jack_lead_queue_id_seq'::regclass);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (xid);


--
-- Name: context_pack_items context_pack_items_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.context_pack_items
    ADD CONSTRAINT context_pack_items_pkey PRIMARY KEY (xid);


--
-- Name: context_packs context_packs_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.context_packs
    ADD CONSTRAINT context_packs_pkey PRIMARY KEY (xid);


--
-- Name: embeddings embeddings_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.embeddings
    ADD CONSTRAINT embeddings_pkey PRIMARY KEY (xid);


--
-- Name: jack_lead_queue jack_lead_queue_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.jack_lead_queue
    ADD CONSTRAINT jack_lead_queue_pkey PRIMARY KEY (id);


--
-- Name: memory_records memory_records_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_pkey PRIMARY KEY (xid);


--
-- Name: source_agents source_agents_agent_key_key; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.source_agents
    ADD CONSTRAINT source_agents_agent_key_key UNIQUE (agent_key);


--
-- Name: source_agents source_agents_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.source_agents
    ADD CONSTRAINT source_agents_pkey PRIMARY KEY (xid);


--
-- Name: source_instances source_instances_instance_key_key; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.source_instances
    ADD CONSTRAINT source_instances_instance_key_key UNIQUE (instance_key);


--
-- Name: source_instances source_instances_pkey; Type: CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.source_instances
    ADD CONSTRAINT source_instances_pkey PRIMARY KEY (xid);


--
-- Name: idx_audit_events_action; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_audit_events_action ON openbrain.audit_events USING btree (action);


--
-- Name: idx_audit_events_correlation_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_audit_events_correlation_xid ON openbrain.audit_events USING btree (correlation_xid);


--
-- Name: idx_audit_events_created_at; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_audit_events_created_at ON openbrain.audit_events USING btree (created_at DESC);


--
-- Name: idx_audit_events_event_type; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_audit_events_event_type ON openbrain.audit_events USING btree (event_type);


--
-- Name: idx_audit_events_record_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_audit_events_record_xid ON openbrain.audit_events USING btree (record_xid);


--
-- Name: idx_context_pack_items_item; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_pack_items_item ON openbrain.context_pack_items USING btree (item_type, item_xid);


--
-- Name: idx_context_pack_items_pack; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_pack_items_pack ON openbrain.context_pack_items USING btree (context_pack_xid);


--
-- Name: idx_context_pack_items_rank; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_pack_items_rank ON openbrain.context_pack_items USING btree (context_pack_xid, rank);


--
-- Name: idx_context_packs_generated_at; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_packs_generated_at ON openbrain.context_packs USING btree (generated_at DESC);


--
-- Name: idx_context_packs_pack_type; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_packs_pack_type ON openbrain.context_packs USING btree (pack_type);


--
-- Name: idx_context_packs_session_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_packs_session_xid ON openbrain.context_packs USING btree (session_xid);


--
-- Name: idx_context_packs_source_agent_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_context_packs_source_agent_xid ON openbrain.context_packs USING btree (source_agent_xid);


--
-- Name: idx_embeddings_owner; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_embeddings_owner ON openbrain.embeddings USING btree (owner_type, owner_xid);


--
-- Name: idx_embeddings_vector_ivfflat; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_embeddings_vector_ivfflat ON openbrain.embeddings USING ivfflat (embedding_vector public.vector_cosine_ops) WITH (lists='100');


--
-- Name: idx_jack_lead_queue_status; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_jack_lead_queue_status ON openbrain.jack_lead_queue USING btree (status) WHERE ((status)::text = ANY ((ARRAY['pending'::character varying, 'failed'::character varying])::text[]));


--
-- Name: idx_memory_records_active_durable; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_active_durable ON openbrain.memory_records USING btree (memory_type, authority_tier, captured_at DESC) WHERE ((status = 'active'::text) AND (retention_class = 'durable'::text));


--
-- Name: idx_memory_records_arag_document_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_arag_document_xid ON openbrain.memory_records USING btree (arag_document_xid) WHERE (arag_document_xid IS NOT NULL);


--
-- Name: idx_memory_records_authority_tier; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_authority_tier ON openbrain.memory_records USING btree (authority_tier);


--
-- Name: idx_memory_records_captured_at; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_captured_at ON openbrain.memory_records USING btree (captured_at DESC);


--
-- Name: idx_memory_records_correlation_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_correlation_xid ON openbrain.memory_records USING btree (correlation_xid);


--
-- Name: idx_memory_records_fingerprint; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_fingerprint ON openbrain.memory_records USING btree (fingerprint);


--
-- Name: idx_memory_records_memory_type; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_memory_type ON openbrain.memory_records USING btree (memory_type);


--
-- Name: idx_memory_records_review_status; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_review_status ON openbrain.memory_records USING btree (review_status);


--
-- Name: idx_memory_records_session_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_session_xid ON openbrain.memory_records USING btree (session_xid);


--
-- Name: idx_memory_records_source_agent_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_source_agent_xid ON openbrain.memory_records USING btree (source_agent_xid);


--
-- Name: idx_memory_records_status; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_memory_records_status ON openbrain.memory_records USING btree (status);


--
-- Name: idx_source_agents_agent_type; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_source_agents_agent_type ON openbrain.source_agents USING btree (agent_type);


--
-- Name: idx_source_agents_status; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_source_agents_status ON openbrain.source_agents USING btree (status);


--
-- Name: idx_source_instances_agent_xid; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_source_instances_agent_xid ON openbrain.source_instances USING btree (agent_xid);


--
-- Name: idx_source_instances_status; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE INDEX idx_source_instances_status ON openbrain.source_instances USING btree (status);


--
-- Name: uq_embeddings_owner_model; Type: INDEX; Schema: openbrain; Owner: emily_rw
--

CREATE UNIQUE INDEX uq_embeddings_owner_model ON openbrain.embeddings USING btree (owner_type, owner_xid, embedding_model);


--
-- Name: context_pack_items trg_context_pack_items_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_context_pack_items_updated_at BEFORE UPDATE ON openbrain.context_pack_items FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: context_packs trg_context_packs_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_context_packs_updated_at BEFORE UPDATE ON openbrain.context_packs FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: embeddings trg_embeddings_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_embeddings_updated_at BEFORE UPDATE ON openbrain.embeddings FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: memory_records trg_memory_records_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_memory_records_updated_at BEFORE UPDATE ON openbrain.memory_records FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: source_agents trg_source_agents_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_source_agents_updated_at BEFORE UPDATE ON openbrain.source_agents FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: source_instances trg_source_instances_updated_at; Type: TRIGGER; Schema: openbrain; Owner: emily_rw
--

CREATE TRIGGER trg_source_instances_updated_at BEFORE UPDATE ON openbrain.source_instances FOR EACH ROW EXECUTE FUNCTION openbrain.set_updated_at();


--
-- Name: audit_events audit_events_source_agent_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.audit_events
    ADD CONSTRAINT audit_events_source_agent_xid_fkey FOREIGN KEY (source_agent_xid) REFERENCES openbrain.source_agents(xid);


--
-- Name: audit_events audit_events_source_instance_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.audit_events
    ADD CONSTRAINT audit_events_source_instance_xid_fkey FOREIGN KEY (source_instance_xid) REFERENCES openbrain.source_instances(xid);


--
-- Name: context_pack_items context_pack_items_context_pack_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.context_pack_items
    ADD CONSTRAINT context_pack_items_context_pack_xid_fkey FOREIGN KEY (context_pack_xid) REFERENCES openbrain.context_packs(xid) ON DELETE CASCADE;


--
-- Name: context_packs context_packs_source_agent_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.context_packs
    ADD CONSTRAINT context_packs_source_agent_xid_fkey FOREIGN KEY (source_agent_xid) REFERENCES openbrain.source_agents(xid);


--
-- Name: context_packs context_packs_source_instance_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.context_packs
    ADD CONSTRAINT context_packs_source_instance_xid_fkey FOREIGN KEY (source_instance_xid) REFERENCES openbrain.source_instances(xid);


--
-- Name: memory_records memory_records_parent_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_parent_xid_fkey FOREIGN KEY (parent_xid) REFERENCES openbrain.memory_records(xid);


--
-- Name: memory_records memory_records_source_agent_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_source_agent_xid_fkey FOREIGN KEY (source_agent_xid) REFERENCES openbrain.source_agents(xid);


--
-- Name: memory_records memory_records_source_instance_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_source_instance_xid_fkey FOREIGN KEY (source_instance_xid) REFERENCES openbrain.source_instances(xid);


--
-- Name: memory_records memory_records_superseded_by_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_superseded_by_xid_fkey FOREIGN KEY (superseded_by_xid) REFERENCES openbrain.memory_records(xid);


--
-- Name: memory_records memory_records_supersedes_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.memory_records
    ADD CONSTRAINT memory_records_supersedes_xid_fkey FOREIGN KEY (supersedes_xid) REFERENCES openbrain.memory_records(xid);


--
-- Name: source_instances source_instances_agent_xid_fkey; Type: FK CONSTRAINT; Schema: openbrain; Owner: emily_rw
--

ALTER TABLE ONLY openbrain.source_instances
    ADD CONSTRAINT source_instances_agent_xid_fkey FOREIGN KEY (agent_xid) REFERENCES openbrain.source_agents(xid);


--
-- Name: SCHEMA openbrain; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA openbrain TO emily_rw;
GRANT ALL ON SCHEMA openbrain TO brodie_rw;
GRANT ALL ON SCHEMA openbrain TO arty_rw;
GRANT ALL ON SCHEMA openbrain TO mary_rw;


--
-- Name: FUNCTION set_updated_at(); Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON FUNCTION openbrain.set_updated_at() TO brodie_rw;
GRANT ALL ON FUNCTION openbrain.set_updated_at() TO arty_rw;
GRANT ALL ON FUNCTION openbrain.set_updated_at() TO mary_rw;


--
-- Name: TABLE audit_events; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.audit_events TO brodie_rw;
GRANT ALL ON TABLE openbrain.audit_events TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.audit_events TO mary_rw;


--
-- Name: TABLE context_pack_items; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.context_pack_items TO brodie_rw;
GRANT ALL ON TABLE openbrain.context_pack_items TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.context_pack_items TO mary_rw;


--
-- Name: TABLE context_packs; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.context_packs TO brodie_rw;
GRANT ALL ON TABLE openbrain.context_packs TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.context_packs TO mary_rw;


--
-- Name: TABLE embeddings; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.embeddings TO brodie_rw;
GRANT ALL ON TABLE openbrain.embeddings TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.embeddings TO mary_rw;


--
-- Name: TABLE jack_lead_queue; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.jack_lead_queue TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.jack_lead_queue TO mary_rw;


--
-- Name: SEQUENCE jack_lead_queue_id_seq; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT SELECT,USAGE ON SEQUENCE openbrain.jack_lead_queue_id_seq TO arty_rw;
GRANT SELECT,USAGE ON SEQUENCE openbrain.jack_lead_queue_id_seq TO mary_rw;


--
-- Name: TABLE memory_records; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.memory_records TO brodie_rw;
GRANT ALL ON TABLE openbrain.memory_records TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.memory_records TO mary_rw;


--
-- Name: TABLE memory_records_with_embeddings; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.memory_records_with_embeddings TO brodie_rw;
GRANT ALL ON TABLE openbrain.memory_records_with_embeddings TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.memory_records_with_embeddings TO mary_rw;


--
-- Name: TABLE source_agents; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.source_agents TO brodie_rw;
GRANT ALL ON TABLE openbrain.source_agents TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.source_agents TO mary_rw;


--
-- Name: TABLE source_instances; Type: ACL; Schema: openbrain; Owner: emily_rw
--

GRANT ALL ON TABLE openbrain.source_instances TO brodie_rw;
GRANT ALL ON TABLE openbrain.source_instances TO arty_rw;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE openbrain.source_instances TO mary_rw;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: openbrain; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT ALL ON SEQUENCES TO arty_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT ALL ON SEQUENCES TO brodie_rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: openbrain; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT ALL ON TABLES TO emily_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT ALL ON TABLES TO arty_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT ALL ON TABLES TO brodie_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA openbrain GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO mary_rw;


--
-- PostgreSQL database dump complete
--

\unrestrict CbGH01KGrnwyKUZj3PKTcsqDPfvcfjqpaClbBhnWqpemN1Ni433yYJUMczXB78P

