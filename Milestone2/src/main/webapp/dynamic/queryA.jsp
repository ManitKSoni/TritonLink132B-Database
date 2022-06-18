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
						<form action="queryA.jsp" method="get">
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
						<th>SSN</th>
					</tr>
					<tr>
						<td><%= request.getParameter("STUDENT_ID") %></td>
						<td><%= rs.getString("FIRST_NAME") %></td>
						<td><%= rs.getString("MIDDLE_NAME") %></td>
						<td><%= rs.getString("LAST_NAME") %></td>
						<td><%= rs.getInt("SSN") %></td>
					</tr>
				</table>
				<table>
					<tr>
						<th>Section ID</th>
						<th>Year</th>
						<th>Qtr</th>
						<th>Course ID</th>
						<th>Title</th>
						<th>Enroll Limit</th>
						<th>Instructor Name</th>
						<th>Grade Option</th>
						<th>Units</th>
					</tr>
				<%
					// Gets all courses the student is currently taking
					pstmt = conn.prepareStatement("SELECT * from academic_history where STUDENT_ID = ? and year = 2018 and qtr = 'SPRING' ");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();

					// for each course currently being taken
					while(rs.next()){
						// get the class attrs for the student in course, via the enroll_list_id
						pstmt = conn.prepareStatement("SELECT * from class where COURSE_ID = ? and year = 2018 and qtr = 'SPRING' and ENROLL_LIST_ID IN (SELECT enroll_list_id from enroll_list where STUDENT_ID = ?)");
						pstmt.setString(1, rs.getString("COURSE_ID"));
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID"))); 
						ResultSet rs2 = pstmt.executeQuery();
						// ensured that there is only one since section_ids + enroll_list_id are unique
						rs2.next();

						int enroll_list_id = rs2.getInt("ENROLL_LIST_ID");
						// get the units and grade option attrs for the student in course
						pstmt = conn.prepareStatement("SELECT GRADE, UNITS from enroll_list where ENROLL_LIST_ID = ? and STUDENT_ID = ?");
						pstmt.setInt(1, enroll_list_id);
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						ResultSet rs3 = pstmt.executeQuery();
						rs3.next(); 
				%>
					<tr>
						<td><%= rs2.getString("SECTION_ID") %></td>
						<td><%= rs2.getInt("YEAR") %></td>
						<td><%= rs2.getString("QTR") %></td>
						<td><%= rs2.getInt("COURSE_ID") %></td>
						<td><%= rs2.getString("TITLE") %></td>
						<td><%= rs2.getInt("ENROLL_LIMIT") %></td>
						<td><%= rs2.getString("NAME") %></td>
						<td><%= rs3.getString("GRADE") %></td>
						<td><%= rs3.getInt("UNITS") %></td>
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
