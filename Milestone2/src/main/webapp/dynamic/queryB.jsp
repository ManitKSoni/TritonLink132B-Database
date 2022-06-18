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
				// Use the statement to SELECT all classes ever
				ResultSet rs = statement.executeQuery("SELECT * from class");
				%>
				
				<table>
					<tr>
						<form action="queryB.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="CLASS_SELECT">Choose a Class:</label>

							<select name="CLASS_SELECT" id="CLASS_SELECT">
							  <option value="">--SECTION ID, YEAR, QTR, COURSE ID--</option>
							
				<%
					// Iterate over the ResultSet of all classes
					while ( rs.next() ) {
						String val = "" + rs.getString("SECTION_ID") + "," + rs.getInt("YEAR") + "," + rs.getString("QTR") + "," + rs.getInt("COURSE_ID");
				%>
								<option value="<%= val %>"><%= val %></option>
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
					String[] args = (request.getParameter("CLASS_SELECT")).split(",");
					String section_id = args[0];
					int year = Integer.parseInt(args[1]);
					String qtr = args[2];
					String course_id = args[3];

					// get class instance and * attributes
					PreparedStatement pstmt = conn.prepareStatement("SELECT * from class where SECTION_ID = ? and YEAR = ? and QTR = ? and COURSE_ID = ?");
					pstmt.setString(1, section_id);
					pstmt.setInt(2, year);
					pstmt.setString(3, qtr);
					pstmt.setString(4, course_id);
					rs = pstmt.executeQuery();
					rs.next();
					
					int enroll_list_id = rs.getInt("ENROLL_LIST_ID");

				%>
				<table>
					<tr>
						<th>Course ID</th>
						<th>Quarter</th>
						<th>Year</th>
					</tr>
					<tr>
						<td><%= rs.getString("COURSE_ID") %></td>
						<td><%= rs.getString("QTR") %></td>
						<td><%= rs.getInt("YEAR") %></td>
					</tr>
				</table>
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
						<th>SSN</th>
						<th>Residence</th>
						<th>Username</th>
						<th>Department Name</th>
						<th>Attendance ID</th>
						<th>Grade Option</th>
						<th>Units</th>
					</tr>
				<%
					// go into enroll_list and select * where enroll_list_id is the same as on the in the class instance
					pstmt = conn.prepareStatement("SELECT * from enroll_list where ENROLL_LIST_ID = ?");
					pstmt.setInt(1, enroll_list_id);
					rs = pstmt.executeQuery();

					// for each student enrolled in the class
					while(rs.next()){
						// get the information of current student 
						pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
						pstmt.setInt(1, rs.getInt("STUDENT_ID"));
						ResultSet rs2 = pstmt.executeQuery();
						rs2.next();
				%>
					<tr>
						<td><%= rs2.getInt("STUDENT_ID") %></td>
						<td><%= rs2.getString("FIRST_NAME") %></td>
						<td><%= rs2.getString("MIDDLE_NAME") %></td>
						<td><%= rs2.getString("LAST_NAME") %></td>
						<td><%= rs2.getInt("SSN") %></td>
						<td><%= rs2.getString("RESIDENCE") %></td>
						<td><%= rs2.getString("USERNAME") %></td>
						<td><%= rs2.getString("DEPT_NAME") %></td>
						<td><%= rs2.getInt("ATTENDANCE_ID") %></td>
						<td><%= rs.getString("GRADE") %></td>
						<td><%= rs.getInt("UNITS") %></td>
					</tr>
				<%
						rs2.close();
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
