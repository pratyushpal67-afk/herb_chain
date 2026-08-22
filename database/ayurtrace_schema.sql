--
-- PostgreSQL database dump
--

\restrict YH3HaklNC7I9mdMMSfsZLBtMNcxOwLh5BbkcUMYdWtIZWkuzYtozujxvOJs2mqR

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-08-22 18:44:59

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 223 (class 1259 OID 16439)
-- Name: batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.batches (
    batch_id character varying(30) NOT NULL,
    collector_id integer NOT NULL,
    herb_id integer NOT NULL,
    quantity_kg numeric(10,2) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(10,7) NOT NULL,
    gps_accuracy_m numeric(8,2),
    captured_at timestamp without time zone NOT NULL,
    status character varying(30) DEFAULT 'COLLECTED'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_latitude CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT check_longitude CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))),
    CONSTRAINT check_quantity CHECK ((quantity_kg > (0)::numeric))
);


ALTER TABLE public.batches OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16468)
-- Name: collection_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_photos (
    photo_id integer NOT NULL,
    batch_id character varying(30) NOT NULL,
    photo_url text NOT NULL,
    photo_hash character varying(128),
    captured_at timestamp without time zone,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.collection_photos OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16467)
-- Name: collection_photos_photo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collection_photos_photo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collection_photos_photo_id_seq OWNER TO postgres;

--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 224
-- Name: collection_photos_photo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collection_photos_photo_id_seq OWNED BY public.collection_photos.photo_id;


--
-- TOC entry 222 (class 1259 OID 16427)
-- Name: herbs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.herbs (
    herb_id integer NOT NULL,
    common_name character varying(100) NOT NULL,
    botanical_name character varying(150) NOT NULL,
    plant_part character varying(50),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.herbs OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16426)
-- Name: herbs_herb_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.herbs_herb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.herbs_herb_id_seq OWNER TO postgres;

--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 221
-- Name: herbs_herb_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.herbs_herb_id_seq OWNED BY public.herbs.herb_id;


--
-- TOC entry 220 (class 1259 OID 16408)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(150),
    role character varying(20) DEFAULT 'COLLECTOR'::character varying NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16407)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 4879 (class 2604 OID 16471)
-- Name: collection_photos photo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_photos ALTER COLUMN photo_id SET DEFAULT nextval('public.collection_photos_photo_id_seq'::regclass);


--
-- TOC entry 4874 (class 2604 OID 16430)
-- Name: herbs herb_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herbs ALTER COLUMN herb_id SET DEFAULT nextval('public.herbs_herb_id_seq'::regclass);


--
-- TOC entry 4870 (class 2604 OID 16411)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 5053 (class 0 OID 16439)
-- Dependencies: 223
-- Data for Name: batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batches (batch_id, collector_id, herb_id, quantity_kg, latitude, longitude, gps_accuracy_m, captured_at, status, created_at) FROM stdin;
ASH-2026-496976	1	1	25.00	22.8800100	88.3638330	12.50	2026-08-22 17:26:01.519818	COLLECTED	2026-08-22 17:26:01.519818
\.


--
-- TOC entry 5055 (class 0 OID 16468)
-- Dependencies: 225
-- Data for Name: collection_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_photos (photo_id, batch_id, photo_url, photo_hash, captured_at, uploaded_at) FROM stdin;
1	ASH-2026-496976	https://storage.ayurtrace.io/herbs/ASH-2026-496976/specimen.jpg	e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855	2026-08-22 17:26:01.519818	2026-08-22 17:26:01.519818
\.


--
-- TOC entry 5052 (class 0 OID 16427)
-- Dependencies: 222
-- Data for Name: herbs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.herbs (herb_id, common_name, botanical_name, plant_part, status, created_at) FROM stdin;
1	Ashwagandha	Withania somnifera	Root	ACTIVE	2026-08-22 17:23:56.944367
2	Tulsi	Ocimum sanctum	Leaves	ACTIVE	2026-08-22 17:23:56.944367
3	Brahmi	Bacopa monnieri	Whole Plant	ACTIVE	2026-08-22 17:23:56.944367
4	Shatavari	Asparagus racemosus	Root	ACTIVE	2026-08-22 17:23:56.944367
5	Neem	Azadirachta indica	Leaves	ACTIVE	2026-08-22 17:23:56.944367
\.


--
-- TOC entry 5050 (class 0 OID 16408)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, name, phone, email, role, status, created_at) FROM stdin;
1	Rahul Das	9876543210	rahul@example.com	COLLECTOR	ACTIVE	2026-08-22 17:22:47.135781
\.


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 224
-- Name: collection_photos_photo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_photos_photo_id_seq', 1, true);


--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 221
-- Name: herbs_herb_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.herbs_herb_id_seq', 5, true);


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);


--
-- TOC entry 4893 (class 2606 OID 16456)
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (batch_id);


--
-- TOC entry 4897 (class 2606 OID 16479)
-- Name: collection_photos collection_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_photos
    ADD CONSTRAINT collection_photos_pkey PRIMARY KEY (photo_id);


--
-- TOC entry 4891 (class 2606 OID 16438)
-- Name: herbs herbs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herbs
    ADD CONSTRAINT herbs_pkey PRIMARY KEY (herb_id);


--
-- TOC entry 4885 (class 2606 OID 16425)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4887 (class 2606 OID 16423)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4889 (class 2606 OID 16421)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4894 (class 1259 OID 16485)
-- Name: idx_batches_collector; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_collector ON public.batches USING btree (collector_id);


--
-- TOC entry 4895 (class 1259 OID 16486)
-- Name: idx_batches_herb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_herb ON public.batches USING btree (herb_id);


--
-- TOC entry 4898 (class 1259 OID 16487)
-- Name: idx_photos_batch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_photos_batch ON public.collection_photos USING btree (batch_id);


--
-- TOC entry 4899 (class 2606 OID 16457)
-- Name: batches fk_batch_collector; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT fk_batch_collector FOREIGN KEY (collector_id) REFERENCES public.users(user_id);


--
-- TOC entry 4900 (class 2606 OID 16462)
-- Name: batches fk_batch_herb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT fk_batch_herb FOREIGN KEY (herb_id) REFERENCES public.herbs(herb_id);


--
-- TOC entry 4901 (class 2606 OID 16480)
-- Name: collection_photos fk_photo_batch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_photos
    ADD CONSTRAINT fk_photo_batch FOREIGN KEY (batch_id) REFERENCES public.batches(batch_id) ON DELETE CASCADE;


-- Completed on 2026-08-22 18:45:00

--
-- PostgreSQL database dump complete
--

\unrestrict YH3HaklNC7I9mdMMSfsZLBtMNcxOwLh5BbkcUMYdWtIZWkuzYtozujxvOJs2mqR

