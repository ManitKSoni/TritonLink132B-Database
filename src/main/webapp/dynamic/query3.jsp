<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <body>
    <table>
      <tr>
        <td>
          <jsp:include page="queryMenu.html" />
        </td>
        <td>
        <%-- Set the scripting language to java and --%>
        <%-- import the java.sql package --%>
        <%@ page language="java" import="java.sql.*" %>
        <%
          try {
          // Load Oracle Driver class file
          DriverManager.registerDriver(new org.postgresql.Driver());
          
          // Make a connection to the Oracle datasource
          Connection conn = DriverManager.getConnection
          ("jdbc:postgresql:project?user=postgres&password=Poseidon123@");
        %>
        
        <%
        String action = request.getParameter("action");
        // Create the statement
        Statement statement = conn.createStatement();
        // Use the statement to SELECT the course attributes
        // gets all courses
        ResultSet rs = statement.executeQuery("SELECT * from course");
        %>
        
        <table>
          <tr>
            <form action="query3.jsp" method="get">
              <input type="hidden" value="get" name="action">
              <label for="course-select">Choose a Course:</label>

              <select name="COURSE_ID" id="course-select">
                <option value="">--Please choose an  Course--</option>
              
        <%
          // Iterate over all courses
          while ( rs.next() ) {
        %>
                <option value="<%= rs.getString("COURSE_ID") %>">Course ID: <%= rs.getString("COURSE_ID") %></option>
        <%
          }
        %>
              </select><br>
              <label for="instructor-select">Choose a Instructor:</label>
              <select name="INSTRUCTOR_NAME" id="instructor-select">
                <option value="">--Please choose an  Instructor--</option>
              
        <%
          // Iterate over all possible Instructors
          ResultSet rs3 = statement.executeQuery("SELECT * from faculty");
          while ( rs3.next() ) {
        %>
                <option value="<%= rs3.getString("NAME") %>">Faculty Name: <%= rs3.getString("NAME") %></option>
        <%
          }
        %>
              </select><br>
              <label for="qtr-select">Choose a QTR:</label>
              <select name="QTR" id="qtr-select">
                <option value="">--Please choose an  QTR--</option>
                <option value="FALL">FALL</option>
                <option value="WINTER">WINTER</option>
                <option value="SPRING">SPRING</option>
              </select><br>

              <label for="year-select">Choose a Year:</label>
              <select name="YEAR" id="year-select">
                <option value="">--Please choose a Year--</option>
        
        <%
          // Iterate over all years
          ResultSet rs4 = statement.executeQuery("SELECT DISTINCT YEAR from class order by YEAR ASC");
          while ( rs4.next() ) {
        %>
              <option value="<%= rs4.getInt("YEAR") %>"><%= rs4.getInt("YEAR") %></option>
        <%
          }
        %>
              </select>
              <th><input type="submit" value="Get"></th>
            </form>
          </tr>
        </table>

        <%
        // Check if an get is requested
        if (action != null && action.equals("get")){

          // Get all sections that the given instructor tought in the given year/qtr for given course
          PreparedStatement pstmt = conn.prepareStatement("SELECT * from class where COURSE_ID = ? and QTR = ? and YEAR = ? and NAME = ?");
          pstmt.setString(1, request.getParameter("COURSE_ID"));
          pstmt.setString(2, request.getParameter("QTR"));
          pstmt.setInt(3, Integer.parseInt(request.getParameter("YEAR")));
          pstmt.setString(4, request.getParameter("INSTRUCTOR_NAME"));
          rs = pstmt.executeQuery();

          // create counts table
          statement.executeUpdate("DROP TABLE IF EXISTS counts");
          statement.executeUpdate("CREATE TABLE counts (grade varchar(2), count int)");
          statement.executeUpdate("INSERT into counts values ('A+', 0)");
          statement.executeUpdate("INSERT into counts values ('A', 0)");
          statement.executeUpdate("INSERT into counts values ('A-', 0)");
          statement.executeUpdate("INSERT into counts values ('B+', 0)");
          statement.executeUpdate("INSERT into counts values ('B', 0)");
          statement.executeUpdate("INSERT into counts values ('B-', 0)");
          statement.executeUpdate("INSERT into counts values ('C+', 0)");
          statement.executeUpdate("INSERT into counts values ('C', 0)");
          statement.executeUpdate("INSERT into counts values ('C-', 0)");
          statement.executeUpdate("INSERT into counts values ('D', 0)");


          // iterate over the sections
          while(rs.next()){
            PreparedStatement pstmt2 = conn.prepareStatement("SELECT * from enroll_list where ENROLL_LIST_ID = ?");
            pstmt2.setInt(1, rs.getInt("ENROLL_LIST_ID"));
            ResultSet rs2 = pstmt2.executeQuery();

            // iterate over students in current section
            while(rs2.next()){
              PreparedStatement pstmt3 = conn.prepareStatement("select GRADE from academic_history where STUDENT_ID = ? and YEAR = ? and QTR = ? and COURSE_ID = ?");
              pstmt3.setInt(1, rs2.getInt("STUDENT_ID"));
              pstmt3.setInt(2, Integer.parseInt(request.getParameter("YEAR")));
              pstmt3.setString(3, request.getParameter("QTR"));
              pstmt3.setInt(4, Integer.parseInt(request.getParameter("COURSE_ID")));
              rs3 = pstmt3.executeQuery();

              //guaranteed to have exactly 1 student
              rs3.next();

              // increment the counts table
              PreparedStatement pstmt4 = conn.prepareStatement("UPDATE counts SET COUNT = COUNT + 1 WHERE GRADE = ?");
              pstmt4.setString(1, rs3.getString("GRADE"));
              pstmt4.executeUpdate();
            }
          }

          %>
          <!-- PART2 -->
          <h3>Grade Distribution for Course ID: <%= request.getParameter("COURSE_ID") %>, Taught By: <%= request.getParameter("INSTRUCTOR_NAME") %>, FOR: <%= request.getParameter("QTR") %> <%= request.getParameter("YEAR") %></h3>
        <table>
          <tr>
            <th>Grade</th>
            <th>Count</th>
          </tr>
          <%
          rs4 = statement.executeQuery("SELECT * from counts order by GRADE ASC");
          // iterate over the obtained counts and print them
          while(rs4.next()){
            %>
            <tr>
              <td><%= rs4.getString("GRADE") %></td>
              <td><%= rs4.getInt("COUNT") %></td>
            </tr>
            <%
          }
          %>
        </table>
          <%
          // clear the counts
          statement.executeUpdate("UPDATE counts set COUNT = 0");

          // Get all sections that the given instructor tought in any qtr for given course
          pstmt = conn.prepareStatement("SELECT * from class where COURSE_ID = ? and NAME = ?");
          pstmt.setInt(1, Integer.parseInt(request.getParameter("COURSE_ID")));
          pstmt.setString(2, request.getParameter("INSTRUCTOR_NAME"));
          rs = pstmt.executeQuery();

          // iterate over the sections
          while(rs.next()){
            PreparedStatement pstmt2 = conn.prepareStatement("SELECT * from enroll_list where ENROLL_LIST_ID = ?");
            pstmt2.setInt(1, rs.getInt("ENROLL_LIST_ID"));
            ResultSet rs2 = pstmt2.executeQuery();

            // iterate over students in current section
            while(rs2.next()){
              PreparedStatement pstmt3 = conn.prepareStatement("select GRADE from academic_history where STUDENT_ID = ? and YEAR = ? and QTR = ? and COURSE_ID = ?");
              pstmt3.setInt(1, rs2.getInt("STUDENT_ID"));
              pstmt3.setInt(2, rs.getInt("YEAR"));
              pstmt3.setString(3, rs.getString("QTR"));
              pstmt3.setInt(4, Integer.parseInt(request.getParameter("COURSE_ID")));
              rs3 = pstmt3.executeQuery();

              //guaranteed to have exactly 1 student
              rs3.next();

              // increment the counts table
              PreparedStatement pstmt4 = conn.prepareStatement("UPDATE counts SET COUNT = COUNT + 1 WHERE GRADE = ?");
              pstmt4.setString(1, rs3.getString("GRADE"));
              pstmt4.executeUpdate();
            }
          }

          statement.executeUpdate("DROP TABLE IF EXISTS temp");
          statement.executeUpdate("CREATE TABLE temp (grade DECIMAL(2,1))");
          rs = statement.executeQuery("SELECT * from counts where COUNT > 0");
          int numEntries = 0;
          double gradeSum = 0.0; 

          // iterate over the counts
          while(rs.next()){
            numEntries += rs.getInt("COUNT");
            PreparedStatement pstmt2 = conn.prepareStatement("SELECT NUMBER_GRADE from grade_conversion where LETTER_GRADE = ?");
            pstmt2.setString(1, rs.getString("GRADE"));
            ResultSet rs2 = pstmt2.executeQuery();

            // guaranteed to have exactly 1 entry
            rs2.next();

            // insert decimal value into temp table
            PreparedStatement pstmt3 = conn.prepareStatement("INSERT into TEMP values (?)");
            pstmt3.setDouble(1, rs2.getDouble("NUMBER_GRADE") * rs.getInt("COUNT"));
            pstmt3.executeUpdate();
          }

          rs = statement.executeQuery("SELECT SUM(grade) from temp");
          rs.next();
          gradeSum = rs.getDouble(1);

          %>
          <!-- PART 3 -->
        <h3>Grade Distribution for Course ID: <%= request.getParameter("COURSE_ID") %>, Taught By: <%= request.getParameter("INSTRUCTOR_NAME") %>, For All QRTS</h3>
        <table>
          <tr>
            <th>Grade</th>
            <th>Count</th>
          </tr>
          <%
          rs4 = statement.executeQuery("SELECT * from counts order by GRADE ASC");
          // iterate over the obtained counts and print them
          while(rs4.next()){
            %>
            <tr>
              <td><%= rs4.getString("GRADE") %></td>
              <td><%= rs4.getInt("COUNT") %></td>
            </tr>
            <%
          }
          %>
        </table>
        <!-- PART 5 -->
        <p>GPA: <%= gradeSum / numEntries %></p>
        
        <%
          // clear the counts
          statement.executeUpdate("UPDATE counts set COUNT = 0");

          // Get all sections that any instructor tought in any qtr for given course
          pstmt = conn.prepareStatement("SELECT * from class where COURSE_ID = ?");
          pstmt.setString(1, request.getParameter("COURSE_ID"));
          rs = pstmt.executeQuery();

          // iterate over the sections
          while(rs.next()){
            PreparedStatement pstmt2 = conn.prepareStatement("SELECT * from enroll_list where ENROLL_LIST_ID = ?");
            pstmt2.setInt(1, rs.getInt("ENROLL_LIST_ID"));
            ResultSet rs2 = pstmt2.executeQuery();

            // iterate over students in current section
            while(rs2.next()){
              PreparedStatement pstmt3 = conn.prepareStatement("select GRADE from academic_history where STUDENT_ID = ? and YEAR = ? and QTR = ? and COURSE_ID = ?");
              pstmt3.setInt(1, rs2.getInt("STUDENT_ID"));
              pstmt3.setInt(2, rs.getInt("YEAR"));
              pstmt3.setString(3, rs.getString("QTR"));
              pstmt3.setString(4, request.getParameter("COURSE_ID"));
              rs3 = pstmt3.executeQuery();

              //guaranteed to have exactly 1 student
              rs3.next();

              // increment the counts table
              PreparedStatement pstmt4 = conn.prepareStatement("UPDATE counts SET COUNT = COUNT + 1 WHERE GRADE = ?");
              pstmt4.setString(1, rs3.getString("GRADE"));
              pstmt4.executeUpdate();
            }
          }
          %>
        <!-- PART 4 -->
        <h3>Grade Distribution for Course ID: <%= request.getParameter("COURSE_ID") %>, For All QRTS and Instructors</h3>
        <table>
          <tr>
            <th>Grade</th>
            <th>Count</th>
          </tr>
          <%
          rs4 = statement.executeQuery("SELECT * from counts order by GRADE ASC");
          // iterate over the obtained counts and print them
          while(rs4.next()){
            %>
            <tr>
              <td><%= rs4.getString("GRADE") %></td>
              <td><%= rs4.getInt("COUNT") %></td>
            </tr>
            <%
          }
          %>
        </table>
        <%
          // end of processing if statement
        }


        // Close the ResultSet
        rs.close();
        // Close the Statement
        statement.close();
        // Close the Connection
        conn.close();
        } catch (SQLException sqle) {
        out.println(sqle.getMessage());
        } catch (Exception e) {
        out.println(e.getMessage());
        }
        %>
        </table>
        </td>
      </tr>
    </table>
  </body>
</html>
