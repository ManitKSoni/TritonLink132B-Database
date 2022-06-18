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
				<%@ page language="java" import="java.sql.*, java.util.*" %>
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
				// gets all ms ever enrolled
				ResultSet rs = statement.executeQuery("SELECT * from ms");
				%>
				
				<table>
					<tr>
						<form action="queryE.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="student-select">Choose a MS Student:</label>

							<select name="STUDENT_ID" id="student-select">
							  <option value="">--Please choose an  MS--</option>
							
				<%
					// Iterate over all ms ever enrolled
					while ( rs.next() ) {
						PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
						pstmt.setInt(1, rs.getInt("STUDENT_ID"));
						ResultSet rs2 = pstmt.executeQuery();
						rs2.next();

				%>
								<option value="<%= rs.getInt("STUDENT_ID") %>">ID: <%= rs2.getInt("STUDENT_ID") %>, Name: <%= rs2.getString("FIRST_NAME") %> <%= rs2.getString("MIDDLE_NAME") %> <%= rs2.getString("LAST_NAME") %></option>
				<%

					}
				%>
							</select><br>
							<label for="degree-select">Choose a Degree:</label>
							<select name="DEGREE_NAME" id="degree-select">
							  <option value="">--Please choose an  Degree--</option>
							
				<%
					// Iterate over all possible degrees
					ResultSet rs3 = statement.executeQuery("SELECT * from degree where DEGREE_TYPE = 'M.S'");
					while ( rs3.next() ) {
				%>
								<option value="<%= rs3.getString("DEGREE_NAME") %>">Name: <%= rs3.getString("DEGREE_NAME") %>, Type: <%= rs3.getString("DEGREE_TYPE") %></option>
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
					boolean isTaking = true;

					PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					rs.next();
					%>
					<!-- PART 1 Display Student Attrs-->
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
						<th>SSN</th>
					</tr>
					<tr>
						<td><%= rs.getInt("STUDENT_ID") %></td>
						<td><%= rs.getString("FIRST_NAME") %></td>
						<td><%= rs.getString("MIDDLE_NAME") %></td>
						<td><%= rs.getString("LAST_NAME") %></td>
						<td><%= rs.getInt("SSN") %></td>
					</tr>
				</table>
					<%

					// get the degree_requirement_id for the student's degree
					pstmt = conn.prepareStatement("SELECT DEGREE_REQUIREMENT_ID from degree where STUDENT_ID = ? and DEGREE_NAME = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setString(2, request.getParameter("DEGREE_NAME"));
					rs = pstmt.executeQuery();
					
					int degree_requirement_id = 0;
					if(rs.next()){
						degree_requirement_id = rs.getInt("DEGREE_REQUIREMENT_ID");
					}
					else{
						// take best guess to get degree_requirement_id (should work)
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT DEGREE_REQUIREMENT_ID from degree where DEGREE_NAME = ?");
						pstmt2.setString(1, request.getParameter("DEGREE_NAME"));
						ResultSet rs2 = pstmt2.executeQuery();
						rs2.next();
						degree_requirement_id = rs2.getInt("DEGREE_REQUIREMENT_ID");

						isTaking = false;
					}

					// gets all concentrations for degree
					pstmt = conn.prepareStatement("SELECT * from course_category where DEGREE_REQUIREMENT_ID = ?");
					pstmt.setInt(1, degree_requirement_id);
					rs = pstmt.executeQuery();
					%>
					<!-- Part 4 DISPLAY OTHER CLASSES YOU CAN TAKE FOR CONCENTRATION AND NEXT DATE AVAILABLE -->
				<h3>List of Concentrations and corresponding courses you can take</h3>
				<ul>
					<%
					// iterates over all concentrations required by the degree
					int numDegreeUnitsRequired = 0; // number of units required for degree

					// list of concentrations completed
					ArrayList<String> completed = new ArrayList<String>();
					ArrayList<String> nameList = new ArrayList<String>();
					ArrayList<String> gpaList = new ArrayList<String>();
					ArrayList<Integer> unitsList = new ArrayList<Integer>();
					
					// iterate over concentrations
					while(rs.next()){
						statement.executeUpdate("DROP TABLE IF EXISTS temp");
						statement.executeUpdate("CREATE TABLE temp (grade DECIMAL(2,1), units int)");

						// list concentration name
					%>
						<li><%= rs.getString("NAME") %></li>
						<ul>
					<%
						//  number of units required for category
						int numCategoryUnitsRequired = rs.getInt("MIN_UNITS");

						// counted units towards the currConcentration
						int counted = 0;
						String currConcentration = rs.getString("NAME");

						// iterate all courses under the current concentration
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT * from course where CONCENTRATION = ?");
						pstmt2.setString(1, currConcentration);
						ResultSet rs2 = pstmt2.executeQuery();
						while(rs2.next()){

							PreparedStatement pstmt3 = conn.prepareStatement("SELECT * from academic_history where COURSE_ID = ? and STUDENT_ID = ?");
							pstmt3.setInt(1, rs2.getInt("COURSE_ID"));
							pstmt3.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
							rs3 = pstmt3.executeQuery();
							boolean passed = false;

							// if student took the class (iterate over instances they took the class)
							while(rs3.next()){
								PreparedStatement pstmt4 = conn.prepareStatement("SELECT NUMBER_GRADE from grade_conversion where LETTER_GRADE = ?");
								pstmt4.setString(1, rs3.getString("GRADE"));
								ResultSet rs4 = pstmt4.executeQuery();
								rs4.next();
								double recievedGrade = rs4.getDouble("NUMBER_GRADE");

								pstmt4 = conn.prepareStatement("SELECT NUMBER_GRADE from grade_conversion where LETTER_GRADE = ?");
								pstmt4.setString(1, rs.getString("MIN_AVG_GRADE"));
								rs4 = pstmt4.executeQuery();
								rs4.next();
								double neededGrade = rs4.getDouble("NUMBER_GRADE");

								int unitsCounted = 0;

								// if student did well enough to earn credit
								if(recievedGrade >= neededGrade){
									// increment counted units toward curr concentration
									unitsCounted = rs3.getInt("UNITS");
									counted += rs3.getInt("UNITS");
									passed = true;
								}
								// insert the grade and units into the temp table
								PreparedStatement pstmt5 = conn.prepareStatement("INSERT into temp values (?,?)");
								pstmt5.setDouble(1, recievedGrade);
								pstmt5.setInt(2, unitsCounted);
								pstmt5.executeUpdate();

								if(passed){
									break;
								}

							}

							// if did not pass then display it and next time offered
							if(!passed){
								PreparedStatement pstmt5 = conn.prepareStatement("(SELECT QTR, YEAR from class where COURSE_ID = ?  and YEAR > 2018 UNION SELECT QTR, YEAR from class where COURSE_ID = ?  and YEAR = 2018 and QTR = 'FALL') order by YEAR ASC, QTR DESC");
								pstmt5.setInt(1, rs2.getInt("COURSE_ID"));
								pstmt5.setInt(2, rs2.getInt("COURSE_ID"));
								ResultSet rs5 = pstmt5.executeQuery();
								if(rs5.next()){
								%>
								<li><%= rs2.getInt("COURSE_ID") %> <%= rs5.getString("QTR") %> <%= rs5.getInt("YEAR") %></li>
								<%
								}
								else{
								%>
								<li><%= rs2.getInt("COURSE_ID") %></li>
								<%
								}
							}
						}
					%>
						</ul>
					<%

						// get the average grade and total units for concentration
						PreparedStatement pstmt6 = conn.prepareStatement("SELECT AVG(GRADE) as gpa, SUM(UNITS) as numUnits from temp");
						ResultSet rs6 = pstmt6.executeQuery();

						String gpa = "N/A";
						int units = 0;
						// if some classes were taken
						if(rs6.next() && (rs6.getDouble("gpa") > 1) ){
							PreparedStatement pstmt7 = conn.prepareStatement("SELECT LETTER_GRADE from grade_conversion where NUMBER_GRADE = ?");
							pstmt7.setDouble(1, rs6.getDouble("gpa"));
							ResultSet rs7 = pstmt7.executeQuery();
							rs7.next();

							gpa = rs7.getString("LETTER_GRADE");
							units = rs6.getInt("numUnits");
						}

						// add to the lists for current concentration
						nameList.add(rs.getString("NAME"));
						gpaList.add(gpa);
						unitsList.add(units);
						
						numDegreeUnitsRequired+= rs.getInt("min_units");
						// if student has earned at least the min amount of units for the category
						if(counted >= rs.getInt("min_units")){
							completed.add(rs.getString("NAME"));
						}

						// end of while (listing concentrations)
					}
				%>
				</ul>
				
				<!-- PART 2 DISPLAY CONCENTRATIONS the STUDENT HAS COMPLETED -->
				<h3>CONCENTRATIONS COMPLETED BY STUDENT</h3>
				<ul>
				<%
					// gets all course_category
					while(!completed.isEmpty()){
						// display curr complete concentration
						%>
						<li><%= completed.get(0) %></li>
						<%
						completed.remove(0);
					}
				%>
				</ul>

				<!-- PART 5 DISPLAY GPA + UNITS PER CONCENTRATION -->
				<h3>GPA + UNITS TAKEN PER CONCENTRATION</h3>

				<ul>
				<%
					while(!nameList.isEmpty()){
						// display the GPA + Units completed for curr concentration

						%>
						<li>Concentration Name: <%= nameList.get(0) %> GPA: <%= gpaList.get(0) %> Units: <%= unitsList.get(0) %></li>
						<%
						nameList.remove(0);
						gpaList.remove(0);
						unitsList.remove(0);
					}
				%>
				</ul>
				<%

					// end of processing if get statement
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
				</table>
				</td>
			</tr>
		</table>
	</body>
</html>