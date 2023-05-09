
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.io.*;
public class admin {

    public static void main(String[] args) throws SQLException 
    {
        try
        {
            BufferedReader br = new BufferedReader(new FileReader( "./admin.txt"));
            String line = " ";
            while ((line = br.readLine()) != "#") 
            {
                
                Connection c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/cs301","postgres","3h5t6m");
                String[] arr = line.split(" ",0);                        
                PreparedStatement cStmt=c.prepareCall("insert into myTrains ( number_train,journey_date,num_of_AC,num_of_SL ,AC_filled ,SL_filled ) values(?,?::DATE,?,?,0,0);");
                Date dt= Date.valueOf(arr[1]);
                cStmt.setInt(1, Integer.parseInt(arr[0]));
                cStmt.setDate(2, dt);
                cStmt.setInt(3,Integer.parseInt(arr[2]));
                cStmt.setInt(4,Integer.parseInt(arr[3]));
                cStmt.execute();
                c.close();     
                cStmt.close();
            } 

            br.close();            
        } 
        catch (IOException e) 
        {
            e.printStackTrace();
        }
    }

}
