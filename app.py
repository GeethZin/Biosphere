import flask
import pyodbc

# Initializes app and database connection
app = flask.Flask('biosphere', template_folder='templates')
db_conn = conn = pyodbc.connect(
    'Driver={SQL Server};'
    'Server=DESKTOP-QR078NF\SQLEXPRESS;'
    'Database=BIOSPHERE;'
    'Trusted_Connection=yes;'
)

# Function to handle the root path '/'
@app.route('/')
@app.route('/home')
def home():
    my_user = {'first': 'Luciano', 'last': 'Santos'}
    return flask.render_template('home.html', user=my_user)



# given a result row, extracts and returns the species data
def extract_species(row):
    species = {}
    species['id'] = row[0]
    species['genus'] = row[1]
    species['species'] = row[2]
    species['subspecies'] = row[3]
    species['name'] = species['genus'] + ' ' + species['species']
    if species['subspecies'] is not None:
        species['name'] += ' ' + species['subspecies']
    return species


# Function to handle the species path '/species'
@app.route('/species', defaults={'id': None})
@app.route('/species/<id>')
def species(id):
    cursor = db_conn.cursor()
    if id is None:
        cursor.execute('SELECT * FROM Bio.Species')
        all_species = []
        for row in cursor:
            data = extract_species(row)
            all_species.append(data)
        return flask.render_template('species.html', species=all_species)
    else:
        cursor.execute('SELECT * FROM Bio.Species WHERE sp_id=' + id)
        row = cursor.fetchone()
        if row is None:
            return flask.render_template('error.html', message='Species not found!')
        data = extract_species(row)
        return flask.render_template('species_detail.html', species=data)

# given a result row, extracts and returns the author data


def extract_author(row):
    author = {}
    author['id'] = row[0]
    author['first_name'] = row[1]
    author['middle_name'] = row[2]
    author['last_name'] = row[3]
    author['birthdate'] = row[4]
    author['name'] = author['first_name'] + ' '
    if author['middle_name'] is not None:
        author['name'] += author['middle_name'] + ' '
    author['name'] += author['last_name']
    return author




@app.route('/authors', defaults={'id': None})
@app.route('/authors/<id>')
def authors(id):
    cursor = db_conn.cursor()
    if id is None:
        cursor.execute('SELECT * FROM Bio.Author')
        all_authors = []
        for row in cursor:
            data = extract_author(row)
            all_authors.append(data)
        return flask.render_template('authors.html', authors=all_authors)
    else:
        cursor.execute('SELECT * FROM Bio.Author WHERE au_id=' + id)
        all_authors = []
        row = cursor.fetchone()
        if row is None:
            return flask.render_template('error.html', message='Author not found!')
        data = extract_author(row)
        return flask.render_template('author_detail.html', author=data)
    


# given a result row, extracts and returns the species data
def extract_species1(row):
    species = {}
    species['id'] = row[0]
    species['genus'] = row[1]
    species['species'] = row[2]
    species['subspecies'] = row[3]
    species['name'] = species['genus'] + ' ' + species['species']
    if species['subspecies'] is not None:
        species['name'] += ' ' + species['subspecies']
    return species
    



# Function to handle the species path '/species'
@app.route('/species1', defaults={'id': None})
@app.route('/species1/<id>')
def speciescom(id):
    cursor = db_conn.cursor()
    if id is None:
        cursor.execute('SELECT * FROM Bio.Species')
        all_species = []
        for row in cursor:
            data = extract_species1(row)
            all_species.append(data)
        return flask.render_template('species1.html', species=all_species)
    else:
        cursor.execute('SELECT * FROM Bio.Species' +id )
        row = cursor.fetchone()
        if row is None:
            return flask.render_template('error.html', message='Species not found!')
        data = extract_species1(row)
        return flask.render_template('species_detail.html', species=data)


def extract_publication(row):
    publication = {}
    publication['id'] = row[0]
    publication['year'] = row[1]
    publication['title'] = row[2]
    publication['startPubli'] = row[3]
    publication['endPubli'] = row[4]
    publication['fname'] = row[5] 
    publication['lname'] = row[6]
    publication['name'] = publication['title']
    return publication

def extract_publication2(row):
    publication = {}
    publication['id'] = row[0]
    publication['year'] = row[1]
    publication['title'] = row[2]
    publication['start'] = row[3]
    publication['end'] = row[4]
    publication['fname'] = row[5] 
    publication['lname'] = row[6]
    
    return publication


@app.route('/publication', defaults={'id': None})
@app.route('/publication/<id>')
def publication(id):
    cursor = db_conn.cursor()
    if id is None:
        cursor.execute("SELECT * FROM Bio.Publication")
        all_publication = []
        for row in cursor:
            data = extract_publication(row)
            all_publication.append(data)
        return flask.render_template('publication.html', publication=all_publication)
    else:
        cursor.execute("""\
            SELECT p.pu_id, p.pu_year, p.pu_title, p.pu_page_start, p.pu_page_end, a.au_fname, a.au_lname
            FROM Bio.Publication p, Bio.Au_Writes_Pu w, Bio.Author a
            WHERE p.pu_id = w.pu_id AND w.au_id = a.au_id and p.pu_id =
        """ + id)
        all_publication = []
        row = cursor.fetchone()
        if row is None:
            return flask.render_template('error.html', message='Publication not found!')
        data = extract_publication2(row)
        return flask.render_template('publication_details.html', publication=data)


# Starts listening for requests...
app.run(port=8080, use_reloader=True)
