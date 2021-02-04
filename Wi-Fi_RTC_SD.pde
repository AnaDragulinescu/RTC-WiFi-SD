#include <WaspFrame.h>
#include <WaspSD.h>
#include <WaspWIFI_PRO.h>

// define variable
uint8_t error;
uint8_t socket = SOCKET0;//se va schimba cu SOCKET0 la nevoie/change by SOCKET0 if needed
uint8_t status;
unsigned long previous;

//char ESSID[] = "SmartAgro";
//char PASSW[] = "SA123456";

char ESSID[] = "Lenovo";
char PASSW[] = "!eU84073";


// choose NTP server settings
///////////////////////////////////////
char SERVER1[] = "time.nist.gov";
char SERVER2[] = "wwv.nist.gov";

//"pool.ntp.org";

///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 2;
///////////////////////////////////////


// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE1.TXT";
char* time_date; // stores curent date + time
// define an example string
int data, first_lost,x,b;
char y[3];

// define variable
uint8_t sd_answer;
int sentence=0;   // 1 for deletion on reboot  , anything else for data appended to fiel only
bool IRL_time= true;  //  true for no external data source
int cycle_time=25;  // in seconds
char rtc_str[]="00:00:00:05";  //11 char ps incepe de la 0
unsigned long prev;

void setup()
{

    // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  // 2. Reset to default values
  //////////////////////////////////////////////////
  error = WIFI_PRO.resetValues();

  if (error == 0)
  {    
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }

// 3. Set ESSID
  //////////////////////////////////////////////////
  error = WIFI_PRO.setESSID(ESSID);

  if (error == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }


  //////////////////////////////////////////////////
  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  //////////////////////////////////////////////////
  error = WIFI_PRO.setPassword(WPA2, PASSW);

  if (error == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }


  //////////////////////////////////////////////////
  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  //////////////////////////////////////////////////
  error = WIFI_PRO.softReset();

  if (error == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }


  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));



  //////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////  

  // get actual time
  previous = millis();

  // check connectivity
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {    
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 
  }



  //////////////////////////////////////////////////
  // 3. NTP server
  //////////////////////////////////////////////////  

  // Check if module is connected
  if (status == true)
  {   

//    // 3.1. Set NTP Server (option1)
    error = WIFI_PRO.setTimeServer(1, SERVER1);

    // check response
    if (error == 0)
    {
      USB.println(F("3.1. Time Server1 set OK"));   
    }
    else
    {
      USB.println(F("3.1. Error calling 'setTimeServer' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }
    
    
    // 3.2. Set NTP Server (option2)
    error = WIFI_PRO.setTimeServer(2, SERVER2);

    // check response
    if (error == 0)
    {
      USB.println(F("3.2. Time Server2 set OK"));   
    }
    else
    {
      USB.println(F("3.2. Error calling 'setTimeServer' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }

    // 3.3. Enabled/Disable Time Sync
    if (status == true)
    { 
      error = WIFI_PRO.timeActivationFlag(true);

      // check response
      if( error == 0 )
      {
        USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));   
      }
      else
      {
        USB.println(F("3.3. Error calling 'timeActivationFlag' function"));
        WIFI_PRO.printErrorCode();  
        status = false;        
      } 
    }

    // 3.4. set GMT
    if (status == true)
    {     
      error = WIFI_PRO.setGMT(time_zone);

      // check response
      if (error == 0)
      {
        USB.print(F("3.4. GMT set OK to "));   
        USB.println(time_zone, DEC);
      }
      else
      {
        USB.println(F("3.4. Error calling 'setGMT' function"));
        WIFI_PRO.printErrorCode();       
      } 
    }
  }

//
//  //////////////////////////////////////////////////
//  // 4. Switch OFF
//  //////////////////////////////////////////////////  
//  USB.println(F("4. WiFi switched OFF\n")); 
//  WIFI_PRO.OFF(socket);


  USB.println(F("-----------------------------------------------------------")); 
  USB.println(F("Once the module has the correct Time Server Settings"));
  USB.println(F("it is always possible to request for the Time and"));
  USB.println(F("synchronize it to the Waspmote's RTC")); 
  USB.println(F("-----------------------------------------------------------\n")); 
  delay(5000);
  
  // Init RTC
//  RTC.ON();
//  USB.print(F("Current RTC settings:"));
//  USB.println(RTC.getTime());
//  


  // open USB port
  USB.ON();
  RTC.ON(); // Executes the init process
  first_lost=-7;
//  USB.print(F("Current RTC settings:"));
//  USB.println(RTC.getTime());
  IRL_time=false;

  
  if( IRL_time)
  {
    // Setting date and time [yy:mm:dd:dow:hh:mm:ss]
    RTC.setTime("21:02:01:02:00:00:00");
  }
  else
  {
    // Check if module is connected
  if (status == true)
  {   
    // 3.1. Open FTP session
    error = WIFI_PRO.setTimeFromWIFI();

    // check response
    if (error == 0)
    {
      USB.print(F("3. Set RTC time OK. Time:"));
      USB.println(RTC.getTime());
    }
    else
    {
      USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }
  }

  }

  

   USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());

  USB.println(F("SD_arhive_V2"));
  
  // Set SD ON
  SD.ON();

    if ( sentence==1) 
    {
        // Delete file
        sd_answer = SD.del(filename);
  
       if( sd_answer == 1 )
       {
        USB.println(F("file deleted"));
       }
       else 
       {
        USB.println(F("file NOT deleted"));  
       }

    }
         // Create file IF id doent exist 
         sd_answer = SD.create(filename);
  
         if( sd_answer == 1 )
         {
           USB.println(F("file created"));
         }
         else 
         {
           USB.println(F("file NOT created"));  
         } 
  
       USB.print("loop cycle time[s]:= ");
       USB.println(cycle_time );
      sd_answer = SD.appendln(filename,  "----------------------------------------------------------------------------" );

//pm
USB.ON();
}


void loop()
{
  prev=millis();
  USB.ON();
  SD.ON();


  // create new frame
  frame.createFrame(BINARY, "ceva id");  // farame de trimis 
  

  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
 // data is sent here
    frame.showFrame();



 //frame for local storage
   frame.createFrame(ASCII, "ceva id");
  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

  //frame.showFrame();

  time_date = RTC.getTime(); 
  USB.print(F("time: "));
  USB.println(time_date);  
  
  x=RTC.year;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.month;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.day;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.hour;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.minute;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.second;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );



  //USB.println("random1");
  sd_answer = SD.append(filename,  "  " );
  //USB.println("random2");
  sd_answer = SD.append(filename,  frame.buffer , frame.length );
  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.append(filename,  "ceva date de scris vin aici " );
  sd_answer = SD.append(filename,  "\n" );
  



b=(millis()-prev)/1000;
  USB.print("loop execution time[s]: ");
  USB.println(b);

x=cycle_time%60;  // sec
itoa(x-b-1, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[9]=y[0];
rtc_str[10]=y[1];
x=cycle_time/60%60;  // min
itoa(x, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[6]=y[0];
rtc_str[7]=y[1];
x=cycle_time/3600%3600;  // h
itoa(x, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[3]=y[0];
rtc_str[4]=y[1];




  USB.println("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
  SD.OFF();
  USB.OFF();

  PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);


//delay(66600);
  


};

void lost_frames( int x)
{
  if(first_lost<x and first_lost != -7)
  first_lost=first_lost;
  else
  first_lost=x;
};
//     first_lost++;
//     USB.println( SD.cat( filename, 13 , 53 ) );  citeste de le linia  13  53  de caractere

/* 
int data_resender ( char filename , int first_lost )
{
   USB.println( SD.cat( filename, first_lost , frame.length ) );
  return 1;
}
*/

