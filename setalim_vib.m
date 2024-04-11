function out_cell = setalim_vib(s,cfg,vec_mod,val)
disp('settare la tensione di alimentazione del MotorVibrator (e.g. per modulo 5: 85 20 valore)');
set(s, 'TimeOut', 0.1)
warning('off','all')
tmod = length(vec_mod);
out_cell = cell(tmod,1);
setval = uint8(hex2dec(num2str(val)));
for nmod = 1:length(vec_mod)
    mod = vec_mod(nmod);
    % converti l'id del modulo in esadecimale (per comunicare col bruco)
    modulo = uint8(hex2dec(num2str(80))+mod);    
    data_getalim_vib = [modulo cfg.setvib setval cfg.off cfg.off cfg.off cfg.off];
    fwrite(s,data_getalim_vib)
    out = (['Modulo: ' num2str(mod),' ', fscanf(s)]);
    out_cell{nmod} = out; 
end
disp(out_cell)

end