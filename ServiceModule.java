import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.sql.*;
import java.sql.Date;

class QueryRunner implements Runnable
{
    //  Declare socket for client access
    protected Socket socketConnection;
    static final String JDBC_DRIVER ="org.postgresql.Driver";


    public QueryRunner(Socket clientSocket)
    {
        this.socketConnection =  clientSocket;
    }

    public void run()
    {
      try
        {
            //  Reading data from client
            InputStreamReader inputStream = new InputStreamReader(socketConnection.getInputStream()) ;
            BufferedReader bufferedInput = new BufferedReader(inputStream) ;
            OutputStreamWriter outputStream = new OutputStreamWriter(socketConnection.getOutputStream()) ;
            BufferedWriter bufferedOutput = new BufferedWriter(outputStream) ;
            PrintWriter printWriter = new PrintWriter(bufferedOutput, true) ;
            String clientCommand = "" ;
            String responseQuery = "null" ;
            ResultSet rs=null;

            while(true)
            {
                
                System.out.println("Recieved data <" + clientCommand + "> from client : " + socketConnection.getRemoteSocketAddress().toString());

                // System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

                clientCommand = bufferedInput.readLine();

                if(clientCommand.equals("#")){
                
                    inputStream.close();
                    bufferedInput.close();
                    outputStream.close();
                    bufferedOutput.close();
                    printWriter.close();
                    socketConnection.close();
                return;
            }

               String[] tokarr = clientCommand.split(" "); 
            
               
                String[] namearr=new String[Integer.parseInt(tokarr[0])];
                int st=Integer.parseInt(tokarr[0]);
                for(int p=1;p<=st;p++){

                   int len=tokarr[p].length();
                   if(p==st)
                   namearr[p-1]=tokarr[p];
                   else
                   namearr[p-1]=tokarr[p].substring(0, len-1);
                   
                 //  System.out.println(namearr[p-1]);
                }


  
                try 
                {
                    Date dt= Date.valueOf(tokarr[st+2]);

                    Connection c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/cs301","postgres","3h5t6m");
                    PreparedStatement callSt=c.prepareCall("select * from booking(?,?,?,?::DATE,?);");
                     

                    callSt.setInt(1, Integer.parseInt(tokarr[0]));
                    callSt.setObject(2, namearr);
                    callSt.setInt(3,Integer.parseInt(tokarr[st+1]));
                    callSt.setDate(4,dt);
                    callSt.setString(5,tokarr[st+3]);
                    rs=callSt.executeQuery();
                      if(rs.next()){
                          int x=rs.getInt(1);
                        //   System.out.println (x);
                          if(x==0){

                           responseQuery = "Train is not avaible for given combinations";
                           
                           printWriter.println(responseQuery);
                          }
                          else if(x==1){

                            responseQuery = "seat full";
                           printWriter.println(responseQuery);
                          }
                          else {
                            // System.out.println("--------------------------------");
                            responseQuery = tokarr[0]+" booking successfull ";
                           printWriter.println(responseQuery);
                          }
                          System.out.println (x);
                      } 
                      
                      c.close();
                      callSt.close();

                } 
                
                catch (Exception e) 
                {
                    System.err.println( e.getClass().getName()+": "+ e.getMessage() );
                    System.out.println("database not connected  ");
                    System.exit(0);
                }
                try
                {
                Thread.sleep(60);
                } 
                catch (InterruptedException e)
                {
                    e.printStackTrace();
                }

            }


        }
        catch(IOException e)
        {
            return;
        }
    }
}

/**
 * Main Class to controll the program flow
 */
public class ServiceModule 
{
    // Server listens to port
    static int serverPort = 7008;
    // Max no of parallel requests the server can process
    static int numServerCores = 5;         
    //------------ Main----------------------
    public static void main(String[] args) throws IOException 
    {    
        // Creating a thread pool
        ExecutorService executorService = Executors.newFixedThreadPool(numServerCores);
        
        try (//Creating a server socket to listen for clients
        ServerSocket serverSocket = new ServerSocket(serverPort)) {
            Socket socketConnection = null;
            
            // Always-ON server
            while(true)
            {
                System.out.println("Listening port : " + serverPort+ "\nWaiting for clients...");
                socketConnection = serverSocket.accept();   // Accept a connection from a client
                System.out.println("Accepted client :" + socketConnection.getRemoteSocketAddress().toString()+ "\n");
                //  Create a runnable task
                Runnable runnableTask = new QueryRunner(socketConnection);
                //  Submit task for execution   
                executorService.submit(runnableTask);   
            }
        }
    }
}




