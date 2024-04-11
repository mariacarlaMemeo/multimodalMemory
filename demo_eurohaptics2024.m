%%% COPIED from check_bruchi4.mat

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


%% Cleaning
fclose all;
% clc
close all;
clear all;
out = instrfind;
delete(out);
clear out;

%% Add path
addpath(fullfile(pwd,'additional_scripts'));

%% Settings
rng('shuffle') %chooses a random seed based on the current time

% Caterpilar IDs
vec_mod = [1];
serial_port = 'COM4';
% valore corrispondente a frequenza buzzer
fr_buz = 20; % corrisponde a 926 Hz (più vicino a 1000)
% valore corrispondente all'alimentazione del VibroMotor
alim_vib = 120; % corrisponde a 100;
%create the randomized vector for the demo 
tot_trial = 999;
tot_stim  = 9;
n_sense   = repmat(1:3,tot_trial,tot_stim);%1=touch; 2=audio; 3=vision
n_pos     = repmat(1:3,tot_trial,tot_stim);%1= near wrist; 2=middle; 3=distal

%% apertura
% apro il bruco e setto i parametri di comunicazione (li restituisce come
% output e nell'help)
[s,cfg] = open_bruco(serial_port);

%% operazioni
operation = input('Setta la operazione e premi invio 1=interroga, 2=setta, 3=testa\n','s');

switch operation
    case '1' % interroga
        % richiede la frequenza del buzzer
        out_cell = getalim_vib(s,cfg,vec_mod);
        % richiede la tensione di alimentazione del MotorVibrator
        out_cell = getfr_buz(s,cfg,vec_mod);
    case '2' % setta
        % setta la frequenza del buzzer
        out_cell = setfr_buz(s,cfg,vec_mod,fr_buz);
        % setta la tensione di alimentazione del MotorVibrator
        out_cell = setalim_vib(s,cfg,vec_mod,alim_vib);
    case '3' % testa
        
        
        scegli_demo = input(['Setta la demo e premi invio\n'...
            '1 = Ciascun modulo bruco suona da solo\n',...
            '2 = Ciascun modulo bruco vibra da solo\n',...
            '3 = Ciascun modulo bruco si illumina da solo\n',...
            '4 = Ciascun modulo suona vibra e si illumina allo stesso tempo\n',...
            '5 = Tutti i moduli a)si illuminano, b)vibrano, c)suonano, d) si illuminano, suonano e vibrano contemporaneamente\n',...
            ], 's');
        
        
        
        dur_stim = input('Setta la durata della stimolazione in secondi e premi invio\n');
        
        dur_pausa = input('Setta la durata della pausa tra le stimolazioni in secondi e premi invio\n');
        
        switch scegli_demo            
            case '1'
                % testa la frequenza del buzzer
                test_buz(s,cfg,vec_mod,dur_stim,dur_pausa)
            case '2'
                % testa la tensione di alimentazione del MotorVibrator
                test_vib(s,cfg,vec_mod,dur_stim,dur_pausa)
            case '3'
                % testa il led
                test_led(s,cfg,vec_mod,dur_stim,dur_pausa)
            case '4'
                %testa tutte le stimolazioni
                test_all(s,cfg,vec_mod,dur_stim,dur_pausa)
            case '5'
                %test tutte le stimolazioni su tutti i moduli contemporaneamente
                test_all_natale(s,cfg,vec_mod,dur_stim,dur_pausa)
        end
        
end

