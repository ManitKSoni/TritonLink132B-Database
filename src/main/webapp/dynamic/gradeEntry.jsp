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
				// Check if an insertion is requested
				String action = request.getParameter("action");
				if (action != null && action.equals("insert")) {
					conn.setAutoCommit(false);

					// Create the prepared statement and use it to

          // Check if class valid
          PreparedStatement pstmt = conn.prepareStatement(("SELECT count(*) FROM class WHERE year = ? and UPPER(qtr) = ? and course_id = ? and section_id = ?"));
          pstmt.setInt(1, Integer.parseInt(request.getParameter("YEAR")));
          pstmt.setString(2, request.getParameter("QTR"));
          pstmt.setString(3, request.getParameter("COURSE_ID"));
          pstmt.setString(4, request.getParameter("SECTION_ID"));
          ResultSet rs = pstmt.executeQuery();
          rs.next();

          // if the class exists then insert the grade
          if(rs.getInt(1) != 0){
            // insert into academic_history
            PreparedStatement pstmt2 = conn.prepareStatement(
            ("INSERT INTO academic_history VALUES (?,?,?,?,?,?,?)"));
            
            pstmt2.setString(1, request.getParameter("SECTION_ID"));
            pstmt2.setInt(2, Integer.parseInt(request.getParameter("YEAR")));
            pstmt2.setString(3, request.getParameter("QTR"));
            pstmt2.setString(4, request.getParameter("COURSE_ID"));
            pstmt2.setInt(5, Integer.parseInt(request.getParameter("STUDENT_ID")));
            pstmt2.setString(6, request.getParameter("GRADE"));
            pstmt2.setInt(7, Integer.parseInt(request.getParameter("UNITS")));
            pstmt2.executeUpdate();
            pstmt2.close(); 

          }
          else{
            %>
            <p>Class not found</p>
            <%
          }
					rs.close();
					
					conn.commit();
					conn.setAutoCommit(true);
				}
				%>
				
				<%
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT * FROM academic_history");
				%>
				
				<table>
					<tr>
						<th>Student ID</th>
						<th>Course ID</th>
						<th>Section ID</th>
            			<th>QTR</th>
            			<th>Year</th>
						<th>Number of Units</th>
						<th>Grade</th>
					</tr>
					
					<tr>
						<form action="gradeEntry.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="COURSE_ID"></th>
							<th><input value="" name="SECTION_ID"></th>
              				<th><input value="" name="QTR"></th>
              				<th><input value="" name="YEAR"></th>
							<th><input type="number" value="" name="UNITS"></th>
							<th><input value="" name="GRADE"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet of all classes
					while ( rs.next() ) {
				%>
					<tr>
			            <td><%= rs.getInt("STUDENT_ID") %></td>
			            <td><%= rs.getString("COURSE_ID") %></td>
			            <td><%= rs.getString("SECTION_ID") %></td>
			            <td><%= rs.getString("QTR") %></td>
			            <td><%= rs.getInt("YEAR") %></td>
			            <td><%= rs.getInt("UNITS") %></td>
			            <td><%= rs.getString("GRADE") %></td>
					</tr>
				<%
					}
					rs.close();
				%>
				</table>
				
				<%
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
				</td>
			</tr>
		</table>
	</body>
</html>
