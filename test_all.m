function test_all(s,cfg,vec_mod, dur_stim,dur_pausa)
disp('testare tutte le stimolazioni');
set(s, 'TimeOut', 0.1)
warning('off','all')
tmod = length(vec_mod);
out_cell = cell(tmod,1);
for nmod = 1:length(vec_mod)
    mod = vec_mod(nmod);
    % converti l'id del modulo in esadecimale (per comunicare col bruco)
    modulo = uint8(hex2dec(num2str(80))+mod);    
    
    attiva_buz = [modulo cfg.buz cfg.on cfg.off cfg.off cfg.off];
    disattiva_buz = [modulo cfg.buz cfg.off cfg.off cfg.off cfg.off];
    
     attiva_led = [modulo cfg.led cfg.on cfg.off cfg.off cfg.off];
    disattiva_led = [modulo cfg.led cfg.off cfg.off cfg.off cfg.off];
  
    attiva_vib = [modulo cfg.vib cfg.on cfg.off cfg.off cfg.off];
    disattiva_vib = [modulo cfg.vib cfg.off cfg.off cfg.off cfg.off];
   
    
    disp(['Suona/vibra/illumina modulo:', num2str(mod)])
    fwrite(s,[attiva_buz, attiva_led, attiva_vib]);
    pause(dur_stim)
    fwrite(s,[disattiva_buz, disattiva_led, disattiva_vib]);
    pause(dur_pausa)    
end
end