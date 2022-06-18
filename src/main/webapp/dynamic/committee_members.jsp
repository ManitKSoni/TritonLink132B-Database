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
					("INSERT INTO committee_members VALUES (?,?)"));
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("COMMITTEE_MEMBERS_ID")));
					pstmt.setString(2, request.getParameter("NAME"));
					
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
					"UPDATE committee_members SET NAME = ? WHERE COMMITTEE_MEMBERS_ID = ?");
					
					pstmt.setString(1, request.getParameter("NAME"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("COMMITTEE_MEMBERS_ID")));
					
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
					"DELETE FROM committee_members WHERE COMMITTEE_MEMBERS_ID = ?");
					
					pstmt.setInt(1, Integer.parseInt(request.getParameter("COMMITTEE_MEMBERS_ID")));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM committee_members");
				%>
				
				<table>
					<tr>
						<th>Committee Members ID</th>
						<th>Name</th>
					</tr>
					
					<tr>
						<form action="committee_members.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="COMMITTEE_MEMBERS_ID"></th>
							<th><input value="" name="NAME"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="committee_members.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getInt("COMMITTEE_MEMBERS_ID") %>" name="COMMITTEE_MEMBERS_ID"></td>
							<td><input value="<%= rs.getString("NAME") %>" name="NAME"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="committee_members.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getInt("COMMITTEE_MEMBERS_ID") %>" name="COMMITTEE_MEMBERS_ID">
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