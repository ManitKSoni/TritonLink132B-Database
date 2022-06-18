<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <body>
    <table>
      <tr>
        <td>
          <jsp:include page="menu.html" />
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
            <form action="query5.jsp" method="get">
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

          %>
          <!-- PART1 -->
          <h3>Grade Distribution for Course ID: <%= request.getParameter("COURSE_ID") %>, Taught By: <%= request.getParameter("INSTRUCTOR_NAME") %>, FOR: <%= request.getParameter("QTR") %> <%= request.getParameter("YEAR") %></h3>
        <table>
          <tr>
            <th>Grade</th>
            <th>Count</th>
          </tr>
          <%

          // Get all sections that the given instructor tought in the given year/qtr for given course
          PreparedStatement pstmt = conn.prepareStatement("SELECT * from cpqg where COURSE_ID = ? and QTR = ? and YEAR = ? and PROFESSOR = ? ORDER by GRADE ASC");
          pstmt.setString(1, request.getParameter("COURSE_ID"));
          pstmt.setString(2, request.getParameter("QTR"));
          pstmt.setInt(3, Integer.parseInt(request.getParameter("YEAR")));
          pstmt.setString(4, request.getParameter("INSTRUCTOR_NAME"));
          rs = pstmt.executeQuery();

          while(rs.next()){
            %>
            <tr>
              <td><%= rs.getString("GRADE") %></td>
              <td><%= rs.getInt("COUNT") %></td>
            </tr>
            <%
          }
          %>
        </table>
          <!-- PART 2 -->
        <h3>Grade Distribution for Course ID: <%= request.getParameter("COURSE_ID") %>, Taught By: <%= request.getParameter("INSTRUCTOR_NAME") %>, For All QRTS</h3>
        <table>
          <tr>
            <th>Grade</th>
            <th>Count</th>
          </tr>
          <%
          pstmt = conn.prepareStatement("SELECT * from cpg where COURSE_ID = ? and PROFESSOR = ? ORDER by GRADE ASC");
          pstmt.setString(1, request.getParameter("COURSE_ID"));
          pstmt.setString(2, request.getParameter("INSTRUCTOR_NAME"));
          rs = pstmt.executeQuery();
          while(rs.next()){
            %>
            <tr>
              <td><%= rs.getString("GRADE") %></td>
              <td><%= rs.getInt("COUNT") %></td>
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
