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
					("INSERT INTO weekly_meeting VALUES (?,?,?,?)"));
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("WEEKLY_MEETING_ID")));
					pstmt.setString(2, request.getParameter("TYPE"));
					pstmt.setTimestamp(3, Timestamp.valueOf(request.getParameter("START_TIME")));
					pstmt.setTimestamp(4, Timestamp.valueOf(request.getParameter("END_TIME")));
					
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
					"UPDATE weekly_meeting SET TYPE = ?, END_TIME = ? WHERE WEEKLY_MEETING_ID = ? AND START_TIME = ?");
					
					pstmt.setString(1, request.getParameter("TYPE"));
					pstmt.setTimestamp(2, Timestamp.valueOf(request.getParameter("END_TIME")));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("WEEKLY_MEETING_ID")));
					pstmt.setTimestamp(4, Timestamp.valueOf(request.getParameter("START_TIME")));
					
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
					"DELETE FROM weekly_meeting WHERE WEEKLY_MEETING_ID = ? AND START_TIME = ?");
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("WEEKLY_MEETING_ID")));
					pstmt.setTimestamp(2, Timestamp.valueOf(request.getParameter("START_TIME")));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM weekly_meeting");
				%>
				
				<table>
					<tr>
						<th>Weekly Meeting ID</th>
						<th>Meeting Type</th>
						<th>Start Time</th>
						<th>End Time</th>
					</tr>
					
					<tr>
						<form action="weekly_meeting.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="WEEKLY_MEETING_ID"></th>
							<th><input value="" name="TYPE"></th>
							<th><input value="" name="START_TIME"></th>
							<th><input value="" name="END_TIME"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="weekly_meeting.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getInt("WEEKLY_MEETING_ID") %>" name="WEEKLY_MEETING_ID"></td>
							<td><input value="<%= rs.getString("TYPE") %>" name="TYPE"></td>
							<td><input value="<%= rs.getTimestamp("START_TIME") %>" name="START_TIME"></td>
							<td><input value="<%= rs.getTimestamp("END_TIME") %>" name="END_TIME"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="weekly_meeting.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getInt("WEEKLY_MEETING_ID") %>" name="WEEKLY_MEETING_ID">
							<input type="hidden" value="<%= rs.getTimestamp("START_TIME") %>" name="START_TIME">
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