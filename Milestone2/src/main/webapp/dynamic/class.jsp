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
					("INSERT INTO class VALUES (?,?,?,?,?,?,?,?,?,?,?)"));
					
					pstmt.setString(1, request.getParameter("SECTION_ID"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("YEAR")));
					pstmt.setString(3, request.getParameter("QTR"));
					pstmt.setString(4, request.getParameter("COURSE_ID"));
					pstmt.setString(5, request.getParameter("TITLE"));
					pstmt.setInt(6, Integer.parseInt(request.getParameter("ENROLL_LIMIT")));
					pstmt.setInt(7, Integer.parseInt(request.getParameter("ENROLL_LIST_ID")));
					pstmt.setInt(8, Integer.parseInt(request.getParameter("WAITLIST_ID")));
					pstmt.setString(9, request.getParameter("NAME"));
					pstmt.setInt(10, Integer.parseInt(request.getParameter("WEEKLY_MEETING_ID")));
					pstmt.setInt(11, Integer.parseInt(request.getParameter("REVIEW_MEETING_ID")));
					
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
					"UPDATE class SET TITLE = ?, ENROLL_LIMIT = ?, ENROLL_LIST_ID = ?, WAITLIST_ID = ?, NAME = ?, WEEKLY_MEETING_ID = ?, REVIEW_MEETING_ID = ? WHERE SECTION_ID = ? AND YEAR = ? AND QTR = ? AND COURSE_ID = ?");
					
					pstmt.setString(1, request.getParameter("TITLE"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("ENROLL_LIMIT")));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("ENROLL_LIST_ID")));
					pstmt.setInt(4, Integer.parseInt(request.getParameter("WAITLIST_ID")));
					pstmt.setString(5, request.getParameter("NAME"));
					pstmt.setInt(6, Integer.parseInt(request.getParameter("WEEKLY_MEETING_ID")));
					pstmt.setInt(7, Integer.parseInt(request.getParameter("REVIEW_MEETING_ID")));
					pstmt.setString(8, request.getParameter("SECTION_ID"));
					pstmt.setInt(9, Integer.parseInt(request.getParameter("YEAR")));
					pstmt.setString(10, request.getParameter("QTR"));
					pstmt.setString(11, request.getParameter("COURSE_ID"));
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
					"DELETE FROM class WHERE SECTION_ID = ? AND YEAR = ? AND QTR = ? AND COURSE_ID = ?");
					
					pstmt.setString(1, request.getParameter("SECTION_ID"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("YEAR")));
					pstmt.setString(3, request.getParameter("QTR"));
					pstmt.setString(4, request.getParameter("COURSE_ID"));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM class");
				%>
				
				<table>
					<tr>
						<th>Section ID</th>
						<th>Year</th>
						<th>Quarter</th>
						<th>Course ID</th>
						<th>Title</th>
						<th>Enroll Limit</th>
						<th>Enroll List ID</th>
						<th>Waitlist ID</th>
						<th>Instructor</th>
						<th>Weekly Meeting ID</th>
						<th>Review Meeting ID</th>
					</tr>
					
					<tr>
						<form action="class.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="SECTION_ID"></th>
							<th><input value="" name="YEAR"></th>
							<th><input value="" name="QTR"></th>
							<th><input value="" name="COURSE_ID"></th>
							<th><input value="" name="TITLE"></th>
							<th><input value="" name="ENROLL_LIMIT"></th>
							<th><input value="" name="ENROLL_LIST_ID"></th>
							<th><input value="" name="WAITLIST_ID"></th>
							<th><input value="" name="NAME"></th>
							<th><input value="" name="WEEKLY_MEETING_ID"></th>
							<th><input value="" name="REVIEW_MEETING_ID"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="class.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID"></td>
							<td><input value="<%= rs.getInt("YEAR") %>" name="YEAR"></td>
							<td><input value="<%= rs.getString("QTR") %>" name="QTR"></td>
							<td><input value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID"></td>
							<td><input value="<%= rs.getString("TITLE") %>" name="TITLE"></td>
							<td><input value="<%= rs.getInt("ENROLL_LIMIT") %>" name="ENROLL_LIMIT"></td>
							<td><input value="<%= rs.getInt("ENROLL_LIST_ID") %>" name="ENROLL_LIST_ID"></td>
							<td><input value="<%= rs.getInt("WAITLIST_ID") %>" name="WAITLIST_ID"></td>
							<td><input value="<%= rs.getString("NAME") %>" name="NAME"></td>
							<td><input value="<%= rs.getInt("WEEKLY_MEETING_ID") %>" name="WEEKLY_MEETING_ID"></td>
							<td><input value="<%= rs.getInt("REVIEW_MEETING_ID") %>" name="REVIEW_MEETING_ID"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="class.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID">
							<input type="hidden" value="<%= rs.getInt("YEAR") %>" name="YEAR">
							<input type="hidden" value="<%= rs.getString("QTR") %>" name="QTR">
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