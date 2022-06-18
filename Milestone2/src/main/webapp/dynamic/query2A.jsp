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
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT DISTINCT STUDENT_ID FROM academic_history where year = 2018 and UPPER(qtr) = 'SPRING'");
				%>
				
				<table>
					<tr>
						<form action="query2A.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="student-select">Choose a Student:</label>

							<select name="STUDENT_ID" id="student-select">
							  <option value="">--Please choose an student--</option>
							
				<%
					// Iterate over the ResultSet of all classes
					while ( rs.next() ) {

				%>
								<option value="<%= rs.getInt("STUDENT_ID") %>"><%= rs.getInt("STUDENT_ID") %></option>
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
					PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					rs.next();
				%>
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
					</tr>
					<tr>
						<td><%= request.getParameter("STUDENT_ID") %></td>
						<td><%= rs.getString("FIRST_NAME") %></td>
						<td><%= rs.getString("MIDDLE_NAME") %></td>
						<td><%= rs.getString("LAST_NAME") %></td>
					</tr>
				</table>
				<table>
					<tr>
						<th>Title</th>
						<th>Course</th>
					</tr>
				<%
					// Gets all classes the student cannot take because it conflicts with his current classes
					pstmt = conn.prepareStatement("WITH CurrTime AS (SELECT to_char(wm.start_time, 'day') AS day, to_char(wm.start_time, 'HH24:MI') AS start_time, to_char(wm.end_time, 'HH24:MI') AS end_time FROM class c, academic_history ah, weekly_meeting wm WHERE ah.student_id = ? AND c.section_id = ah.section_id AND c.year = ah.year AND c.qtr = ah.qtr AND c.course_id = ah.course_id AND c.year = 2018 AND c.qtr = 'SPRING' AND c.weekly_meeting_id = wm.weekly_meeting_id), SectionTime AS (SELECT c.title, c.course_id, to_char(wm.start_time, 'day') AS day, to_char(wm.start_time, 'HH24:MI') AS start_time, to_char(wm.end_time, 'HH24:MI') AS end_time FROM class c, weekly_meeting wm WHERE c.weekly_meeting_id = wm.weekly_meeting_id AND c.year = 2018 AND c.qtr = 'SPRING') SELECT DISTINCT s.title, s.course_id FROM SectionTime s, CurrTime c WHERE s.day <> c.day OR ((s.day = c.day AND c.end_time <= s.start_time) OR (s.day = c.day AND c.start_time >= s.end_time))");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));	
					rs = pstmt.executeQuery();
					
					// for each course currently being taken
					while(rs.next()){ 
				%>
						<tr>
							<td><%= rs.getInt("TITLE") %></td>
							<td><%= rs.getInt("COURSE_ID") %></td>
						</tr>
				<%

					}
				%>
				</table>
				<%
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
				</td>
			</tr>
		</table>
	</body>
</html>
