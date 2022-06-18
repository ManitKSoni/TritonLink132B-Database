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
					// INSERT the student attrs INTO the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					("INSERT INTO course VALUES (?,?,?,?,?,?,?,?,?)"));
					
					pstmt.setString(1, request.getParameter("COURSE_ID"));
					pstmt.setString(2, request.getParameter("INSTR_CONSENT"));
					pstmt.setString(3, request.getParameter("GRADE_OPTION"));
					pstmt.setString(4, request.getParameter("LAB_WORK"));
					pstmt.setString(5, request.getParameter("CONCENTRATION"));
					pstmt.setString(6, request.getParameter("DEPT_NAME"));
					pstmt.setInt(7, Integer.parseInt(request.getParameter("MAX_UNITS")));
					pstmt.setInt(8, Integer.parseInt(request.getParameter("MIN_UNITS")));
					pstmt.setInt(9, Integer.parseInt(request.getParameter("PREREQ_LIST_ID")));
					
					pstmt.executeUpdate();
					
					conn.commit();
					conn.setAutoCommit(true);
				}
				
				// Check if an update is requested
				if (action != null && action.equals("update")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// UPDATE the student attributes in the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"UPDATE course SET INSTR_CONSENT = ?, GRADE_OPTION = ?, LAB_WORK = ?, CONCENTRATION = ?, DEPT_NAME = ?, MAX_UNITS = ?, MIN_UNITS = ?, PREREQ_LIST_ID = ? WHERE COURSE_ID = ?");
					
					pstmt.setString(1, request.getParameter("INSTR_CONSENT"));
					pstmt.setString(2, request.getParameter("GRADE_OPTION"));
					pstmt.setString(3, request.getParameter("LAB_WORK"));
					pstmt.setString(4, request.getParameter("CONCENTRATION"));
					pstmt.setString(5, request.getParameter("DEPT_NAME"));
					pstmt.setInt(6, Integer.parseInt(request.getParameter("MAX_UNITS")));
					pstmt.setInt(7, Integer.parseInt(request.getParameter("MIN_UNITS")));
					pstmt.setInt(8, Integer.parseInt(request.getParameter("PREREQ_LIST_ID")));
					pstmt.setString(9, request.getParameter("COURSE_ID"));
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				
				// Check if a delete is requested
				if (action != null && action.equals("delete")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// DELETE the student FROM the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"DELETE FROM course WHERE COURSE_ID = ?");
					
					pstmt.setString(1, request.getParameter("COURSE_ID"));
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				%>
				
				<%
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT * FROM course");
				%>
				
				<table>
					<tr>
						<th>Course ID</th>
						<th>Instructor Consent Required</th>
						<th>Grade Option</th>
						<th>Lab Work</th>
						<th>Concentration</th>
						<th>Department Name</th>
						<th>Max Units</th>
						<th>Min Units</th>
						<th>Prerequisite List ID</th>

					</tr>
					
					<tr>
						<form action="course.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="COURSE_ID"></th>
							<th><input value="" name="INSTR_CONSENT"></th>
							<th><input value="" name="GRADE_OPTION"></th>
							<th><input value="" name="LAB_WORK"></th>
							<th><input value="" name="CONCENTRATION"></th>
							<th><input value="" name="DEPT_NAME"></th>
							<th><input value="" name="MAX_UNITS"></th>
							<th><input value="" name="MIN_UNITS"></th>
							<th><input value="" name="PREREQ_LIST_ID"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="course.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID"></td>
							<td><input value="<%= rs.getString("INSTR_CONSENT") %>" name="INSTR_CONSENT"></td>
							<td><input value="<%= rs.getString("GRADE_OPTION") %>" name="GRADE_OPTION"></td>
							<td><input value="<%= rs.getString("LAB_WORK") %>" name="LAB_WORK"></td>
							<td><input value="<%= rs.getString("CONCENTRATION") %>" name="CONCENTRATION"></td>
							<td><input value="<%= rs.getString("DEPT_NAME") %>" name="DEPT_NAME"></td>
							<td><input value="<%= rs.getInt("MAX_UNITS") %>" name="MAX_UNITS"></td>
							<td><input value="<%= rs.getInt("MIN_UNITS") %>" name="MIN_UNITS"></td>
							<td><input value="<%= rs.getInt("PREREQ_LIST_ID") %>" name="PREREQ_LIST_ID"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="course.jsp" method="get">
							<input type="hidden" value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID">
							<td><input type="submit" value="Delete"></td>
						</form>
					</tr>
				<%
					}
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