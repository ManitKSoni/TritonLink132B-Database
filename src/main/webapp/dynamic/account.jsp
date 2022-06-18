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
					("INSERT INTO account VALUES (?,?,?,?)"));
					
					pstmt.setString(1, request.getParameter("USERNAME"));
					pstmt.setString(2, request.getParameter("PASSWORD"));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("PHONE_NUM_LIST")));
					pstmt.setInt(4, Integer.parseInt(request.getParameter("EMAIL_LIST")));
					
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
					"UPDATE account SET PASSWORD = ?, PHONE_NUM_LIST = ?, EMAIL_LIST = ? WHERE USERNAME = ?");
					
					pstmt.setString(1, request.getParameter("PASSWORD"));
					pstmt.setInt(2, Integer.parseInt(request.getParameter("PHONE_NUM_LIST")));
					pstmt.setInt(3, Integer.parseInt(request.getParameter("EMAIL_LIST")));
					pstmt.setString(4, request.getParameter("USERNAME"));
					
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
					"DELETE FROM account WHERE USERNAME = ?");
					
					pstmt.setString(1, request.getParameter("USERNAME"));
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
				ResultSet rs = statement.executeQuery("SELECT * FROM account");
				%>
				
				<table>
					<tr>
						<th>Username</th>
						<th>Password</th>
						<th>Phone Number List</th>
						<th>Email List</th>
					</tr>
					
					<tr>
						<form action="account.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="USERNAME"></th>
							<th><input value="" name="PASSWORD"></th>
							<th><input value="" name="PHONE_NUM_LIST"></th>
							<th><input value="" name="EMAIL_LIST"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="account.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getString("USERNAME") %>" name="USERNAME"></td>
							<td><input value="<%= rs.getString("PASSWORD") %>" name="PASSWORD"></td>
							<td><input value="<%= rs.getInt("PHONE_NUM_LIST") %>" name="PHONE_NUM_LIST"></td>
							<td><input value="<%= rs.getInt("EMAIL_LIST") %>" name="EMAIL_LIST"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="account.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getString("USERNAME") %>" name="USERNAME">
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