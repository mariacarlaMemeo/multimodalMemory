% 12 luglio 2012/ 20 aprile2018 		iit RBCS EDL A.Maviglia
% Progetto: Tactile Sensor. 		Commessa: P22050			Centro di costo: 22033
% Descrizione:
% Dispositivo indirizzato a uP gestito da PC tramite interfaccia RS485 250.000 baud, 8 bit,  N parity, 1 Stop.
% L’indirizzo è univoco tra 0x00 e 0x1F, possono quindi lavorare in multi-drop sino a 32 oggetti.
% Ogni comando è costituito da 3 bytes, il byte di indirizzo sarà 0x80 + nn (dove nn tra 0x00 e 0x1F).
% Le operazioni previste sono (es. Se il dispositivo fosse il n.5):
% a.	Led On/Off.
% 	On: 0x85 0x22  0x11 .
% 	Off: 0x85 0x22  0x00 .
%
% b.	Vibro-motore On/Off.
% 	On: 0x85 0x21  0x11 .
% 	Off: 0x85 0x21  0x00 .
%
% c.	Buzzer alla frequenza memorizzata (dflt 300Hz) On/Off.
% 	On: 0x85 0x23  0x11 .
% 	Off: 0x85 0x23  0x00 .
%
% Per utilizzare questi comandi andare sul programma di antonio AccessPort.exe in Z:\groups\uvip_lab\sw\bruco\AccessPort137
% Connetti porta usb da: Oprions e seleziona “Hex”
% Importante chiudere matlab pima
% Le rispose appaiono nel terminal. Ogni volta che modifichi qualche impostazione la salvi sul bruco, quindi quando lo riapri in matlab le mantiene
% Altri comandi implementati:
% 1.	Modificare l’indirizzo del dispositivo .
% 	0x85 0x77 0xXX . (0xXX nuovo indirizzo per questo dispositivo)
% 		Il cambio di indirizzo verrà confermato con il messaggio:
% 		“new ID address: n OK”
% 		n=indirizzo decimale del dispositivo (es. 1 per modulo 1 e non 81)
% (NB il modulo 10 lo indicizza come 16 sul software maviglia e lo chiama come 90 da command del programmino Maviglia. Pe rchiamarlo da matlab rimane 10)
%
% 2.	Modificare la frequenza emessa dal buzzer.
% 	0x85 0x24  0xYY .	 (0xYY = (41700/f)-12,9  [300...3000Hz])
% Manda direttamente riga 85 24 YY
% 	Max valore ammesso per 0xYY -> 0x78
% 	es. Per generare 1000Hz:
% 	(41700/1000)-12,9  =28.8 che  arrotondato all’intero [0x1D]
% 	Ia nuova frequenza verrà confermata con il messaggio:
% 	“frequency: f Hz”
%
%
%
%
% 3.	Conoscere la frequenza emessa dal buzzer.
% 	0x85 0x24  0x79	.
% Manda direttamente riga 85 24 79
% 	Provocherà in risposta il messaggio:
%
% 	“frequency: f Hz”
% 	f=frequenza in decimale
%
% 4.	Modificare la tensione di alimentazione del MotorVibrator.
% 	0x85 0x20  0xZZ.	(0xZZ tra 60 e 120 dove 60->2V circa 120->3V circa)
% 	Provocherà in risposta il messaggio:
% Assumiamo che si tratti di Hz, abbiamo notato che ZZ non coincide con il valore di riferimento, il massimo è 78 che corrisponde a 120
% 	“Motor Toff [60..120]: n Value”
% 		n=valore di riferimento della succitata tensione
%
% 5.	Conoscere la tensione di alimentazione del MotorVibrator.
% 	0x85 0x20  0x79.
% 	Provocherà in risposta il messaggio:
%
% 	“Motor Toff [60..120]: n Value”
% 		n=valore di riferimento della succitata tensione
%
%
% All’avviamento il dispositivo lampeggia tante volte quanto vale il suo indirizzo.
% Al momento suono a 3000Hz e vibrazione a 112 Hz
%
%
% Note alla programmazione:
% Un singolo comando viene eseguito dopo circa 20uSec dalla ricezione del relativo set, la trasmissione di 3 bytes a 250 kbaud dura circa 110uSec.
% Qualora fosse necessario inserire più comandi per lo stesso dispositivo utilizzando un’unica stringa di comandi, distanziare gli stessi con almeno 3 bytes non significativi
% (es. x80 x21 x11 x00 x00 x00 x80 x22 x11 x00 x00 x00 x80 x23 x11).

function [s,cfg] = open_bruco(serial_port,varargin)
%% pulizia
fclose all;
% clc
close all;
% clear all;
out = instrfind;
delete(out);
clear out;


BaudRate = 250000;
for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'BaudRate' ...                 
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end



%% gestione bruco
% Le operazioni previste sono (es. Se il dispositivo fosse il n.5):
% a.	Led On/Off.
% 	On: 0x85 0x22  0x11 .
% 	Off: 0x85 0x22  0x00 .
%
% b.	Vibro-motore On/Off.
% 	On: 0x85 0x21  0x11 .
% 	Off: 0x85 0x21  0x00 .
%
% c.	Buzzer alla frequenza memorizzata (dflt 500Hz) On/Off.
% 	On: 0x85 0x23  0x11 .
% 	Off: 0x85 0x23  0x00 .

% Assegnazione delle costanti NON TOCCARE
cfg.vib = hex2dec('21');
cfg.led = hex2dec('22');
cfg.buz = hex2dec('23');
cfg.on = hex2dec('11');
cfg.off = hex2dec('00');

%%%%questo comando hex2dec(num2str concerte in stringa e esodecimale
%per conoscere frequenza
cfg.interroga = hex2dec('79');
%per  frequenza buz
cfg.setbuz = hex2dec('24');
%per  frequenza vibr
cfg.setvib = hex2dec('20');

% devN = 0; % N identificativo del device (0-N)
% dev = uint8(hex2dec(num2str(80+devN)));


% Crea l'oggetto virtuale che mappa la porta seriale
s = serial(serial_port);
% Setting parameters
s.BaudRate = 250000;
% Apri la porta
fopen(s);
disp(s)
disp(cfg)
end