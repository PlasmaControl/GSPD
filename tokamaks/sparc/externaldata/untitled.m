tok = load('sparc_obj_6565.mat').tok_data_struct;
circ = sparc_circ(tok);
tok = connect_tok(tok, circ);