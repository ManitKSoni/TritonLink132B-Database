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
					("jdbc:postgresql:tritonlink?user=postgres");
				%>
				
				<%
				String action = request.getParameter("action");
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT DISTINCT section_id FROM class where year = 2018 and UPPER(qtr) = 'SPRING'");
				%>
				
				<table>
					<tr>
						<form action="query2B.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="section-select">Choose a Section:</label>

							<select name="SECTION_ID" id="section-select">
							  <option value="">--Please choose an section--</option>
							
				<%
					// Iterate over the ResultSet of all classes
					while ( rs.next() ) {

				%>
								<option value="<%= rs.getInt("SECTION_ID") %>"><%= rs.getInt("SECTION_ID") %></option>
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
					PreparedStatement pstmt = conn.prepareStatement("SELECT * from class where SECTION_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("SECTION_ID")));
					rs = pstmt.executeQuery();
					rs.next();
				%>
				<table>
					<tr>
						<th>Section ID</th>
						<th>Course</th>
					</tr>
					<tr>
						<td><%= rs.getInt("SECTION_ID") %></td>
						<td><%= rs.getString("COURSE") %></td>
					</tr>
				</table>
				<table>
					<tr>
						<th>Title</th>
						<th>Course</th>
					</tr>
				<%
					// Gets all classes the student cannot take because it conflicts with his current classes
					pstmt = conn.prepareStatement("");
					rs = pstmt.executeQuery();
					// for each course currently being taken
					while(rs.next()){
						// get the class attrs for the student in course, via the enroll_list_id
						pstmt = conn.prepareStatement("SELECT * from class where COURSE_ID = ? and year = 2018 and qtr = 'SPRING' and ENROLL_LIST_ID IN (SELECT enroll_list_id from enroll_list where STUDENT_ID = ?)");
						pstmt.setInt(1, rs.getInt("COURSE_ID"));
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
						<td><%= rs2.getInt("TITLE") %></td>
						<td><%= rs2.getInt("COURSE_ID") %></td>
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
